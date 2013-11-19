# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'spec_helper'

module Microphite
  shared_examples 'a microphite socket client' do |transport|
    before_block = Proc.new do
      @server = Helpers::SingleServe.new(transport)
      client_options = { host: 'localhost', port: @server.port, transport: transport }
      @client = Client::Socket.new(client_options)
    end
    after_block = Proc.new {}

    before do
      instance_eval &before_block
    end

    it_should_behave_like 'a microphite client', before_block, after_block

    describe :write do
      it 'should handle Symbol and String keys' do
        @client.write(key1: 1)
        @client.write(key2: 2, key3: 3)
        @client.write('key4' => 4)
        @client.write('key5' => 5, 'key6' => 6)
        @client.write('key7' => 7, :key8 => 8)
        @client.write(:key9 => 9, 'key10' => 10)
        @client.close

        lines = @server.bytes
        (1..10).each do |n|
          lines.should match(/^key#{n} #{n}\.0* \d+$/)
        end
      end

      it 'should handle Integer and Float values' do
        @client.write(key1: 1)
        @client.write(key2: 2.5)
        @client.close

        lines = @server.bytes
        lines.should match(/^key1 1\.0* \d+$/)
        lines.should match(/^key2 2\.50* \d+$/)
      end
    end

    describe :gather do
      it 'should handle Symbol and String keys' do
        @client.gather(key1: 1)
        @client.gather(key2: 2, key3: 3)
        @client.gather('key4' => 4)
        @client.gather('key5' => 5, 'key6' => 6)
        @client.gather('key7' => 7, :key8 => 8)
        @client.gather(:key9 => 9, 'key10' => 10)
        @client.close

        lines = @server.bytes
        (1..10).each do |n|
          lines.should match(/^key#{n} #{n}\.0* \d+$/)
        end
      end

      it 'should handle Integer and Float values' do
        @client.gather(key1: 1)
        @client.gather(key2: 2.5)
        @client.close

        lines = @server.bytes
        lines.should match(/^key1 1\.0* \d+$/)
        lines.should match(/^key2 2\.50* \d+$/)
      end

      it 'should accumulate data' do
        (1..10).each do
          @client.gather(key1: 1)
          @client.gather('key2' => 2)
          @client.gather(:key3 => 3, 'key4' => 4)
        end
        @client.close

        lines = @server.bytes
        (1..4).each do |n|
          lines.should match(/^key#{n} #{n * 10}\.0* \d+$/)
        end
      end
    end

    describe :time do
      it 'should generate sensible values' do
        before = Time.now.to_f
        @client.time(:key) { 42 }
        after = Time.now.to_f
        outer_timing = after - before

        @client.close
        lines = @server.bytes
        pattern = /^key (?<value>[0-9.]+) \d+$/

        lines.should match(pattern)
        value = pattern.match(lines)[:value]
        value.should_not eq nil
        expect { value > 0 and value < outer_timing }.to be_true
      end
    end
  end

  describe Client::Socket do
    context 'tcp' do
      it_should_behave_like 'a microphite socket client', :tcp
    end

    context 'udp' do
      it_should_behave_like 'a microphite socket client', :udp
    end
  end
end
