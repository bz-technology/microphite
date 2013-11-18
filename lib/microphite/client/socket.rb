# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'socket'

module Microphite
  module Client
    class Socket
      def initialize(host, port=2003, transport=:udp)
        @host = host
        @port = port
        @transport = transport
      end

      def write(metrics)
        if metrics.is_a? Hash
          metrics.each_pair do |key, value|
            begin
              new_socket
              @socket.send("#{key} #{value} #{Time.now.to_i}\n", 0)
              @socket.close
            rescue
            end
          end
        end
      end

      def gather(metrics)
        true
      end

      def prefix(prefix, &block)
        block.call
      end

      def every(seconds, &block)
      end

      def shutdown(timeout=nil)
        true
      end

      private

      def new_socket
        case @transport
          when :tcp
            @socket = TCPSocket.new(@host, @port)
          when :udp
            @socket = UDPSocket.new
            @socket.connect(@host, @port)
          else
            raise(ArgumentError, "transport type is invalid: #{@transport}")
        end
      end
    end
  end
end
