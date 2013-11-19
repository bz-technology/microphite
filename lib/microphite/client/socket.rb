# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'socket'
require 'thread'

module Microphite
  module Client
    class Socket < Base
      def initialize(options)
        defaults = {
            port: 2003,           # Server port
            transport: :udp,      # Transport: :tcp or :udp
        }
        params = defaults.merge(options)

        raise(ArgumentError, ':host option missing') unless params.has_key? :host

        # Read-only state
        @host = params[:host]
        @port = params[:port]
        @prefix = params[:prefix]
        @transport = params[:transport]

        @gather_stack = []
        @write_stack = []
        @lock = Mutex.new

        @thread = Thread.new do
          worker_loop
        end
      end

      def write(metrics)
        push(@write_stack, Timestamped.new(metrics.clone)) if metrics.is_a? Hash
        true
      end

      def gather(metrics)
        push(@gather_stack, Timestamped.new(metrics.clone)) if metrics.is_a? Hash
        true
      end

      def close(timeout=nil)
        # FIXME
        @socket.close unless @socket.nil?
        @thread.kill if @thread.alive?
        true
      end

      private

      def worker_loop
        loop do
          begin
            writes = nil
            gathers = nil

            @lock.synchronize do
              # Swap existing stacks with new ones
              writes, @write_stack = @write_stack, []
              gathers, @gather_stack = @gather_stack, []
            end

            ensure_connected
            [writes, gathers].each do |stack|
              stack.each do |metrics|
                metrics.each_pair do |key, value|
                  @socket.send("#{key} #{value} #{Time.now.to_i}\n", 0)
                end
              end
            end
          rescue
            # Protection from garbage input
          end
        end
      end

      def push(stack, value)
        @lock.synchronize do
          stack << value
          pushed = true
        end
      end

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


      class Timestamped
        attr_accessor :value, :time

        def initialize(value)
          @value = value
          @time = Time.now.to_i
        end
      end
    end
  end
end
