# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'spec_helper'

module Microphite
  shared_examples 'microphite socket client' do |transport|
    include_examples 'microphite client', Client::Socket.new('localhost', 2003, transport)

    before do
      @server = Helpers::SingleServe.new(transport)
      @client = Client::Socket.new('localhost', @server.port, transport)
    end

    describe 'write' do
      it 'should support symbol and string metrics' do
        @client.write(key1: 1)
        @client.write(key2: 2, key3: 3)
        @client.write('key4' => 4)
        @client.write('key5' => 5, 'key6' => 6)
        @client.write('key7' => 7, :key8 => 8)
        @client.write(:key9 => 9, 'key10' => 10)
        @client.shutdown

        lines = @server.bytes
        (1..10).each do |n|
          lines.should match(/^key#{n} #{n} \d+$/)
        end
      end
    end

    describe 'gather' do
      it 'should support symbol and string metrics' do
        @client.gather(key1: 1)
        @client.gather(key2: 2, key3: 3)
        @client.gather('key4' => 4)
        @client.gather('key5' => 5, 'key6' => 6)
        @client.gather('key7' => 7, :key8 => 8)
        @client.gather(:key9 => 9, 'key10' => 10)
        @client.shutdown

        lines = @server.bytes
        (1..10).each do |n|
          lines.should match(/^key#{n} #{n} \d+$/)
        end
      end

      it 'should accumulate data' do
        (1..10).each do
          @client.gather(key1: 1)
          @client.gather('key2' => 2)
          @client.gather(key3 => 3, 'key4' => 4)
        end
        @client.shutdown

        lines = @server.bytes
        (1..10).each do |n|
          lines.should match(/^key#{n} #{n * 10} \d+$/)
        end
      end
    end
  end

  describe Client::Socket do
    context 'tcp' do
      include_examples 'microphite socket client', :tcp
    end

    context 'udp' do
      include_examples 'microphite socket client', :udp
    end
  end
end
