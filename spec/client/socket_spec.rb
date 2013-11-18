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
      it 'should correctly format a single metric' do
        @client.write(key: 0)
        @server.bytes.should match(/^key 0 \d+\n$/)
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
