# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'socket'

module Microphite
  module Client
    class Socket < Base
      def initialize(host, port=2003, transport=:udp)
        @host = host
        @port = port
        @transport = transport
      end

      def write(metrics)
        if metrics.is_a? Hash
          begin
            ensure_connected
            metrics.each_pair do |key, value|
              @socket.send("#{key} #{value} #{Time.now.to_i}\n", 0)
            end
          rescue
          end
        end
      end

      def gather(metrics)
        if metrics.is_a? Hash
          begin
            ensure_connected
            metrics.each_pair do |key, value|
              @socket.send("#{key} #{value} #{Time.now.to_i}\n", 0)
            end
          rescue
          end
        end
      end

      def shutdown(timeout=nil)
        @socket.close unless @socket.nil?
      end

      private

      def ensure_connected
        if @socket.nil?
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
end
