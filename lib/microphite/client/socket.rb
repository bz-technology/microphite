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
            prefix: '',           # Prefix every key with this
            transport: :udp,      # Transport: tcp or udp
            flush_interval: 10,   # How often to flush gathered metrics
            limit: 1000000,       # Size limit for gather and write stacks
            min_delay: 2,         # Initial delay for write failures (seconds)
            max_delay: 60         # Maximum delay for write failures (seconds)
        }
        params = defaults.merge(options)

        raise(ArgumentError, ':host option missing') unless params.has_key? :host

        # Read-only state
        @host = params[:host]
        @port = params[:port]
        @prefix = params[:prefix] unless params[:prefix].nil?
        @transport = params[:transport]
        @flush_interval = params[:flush_interval]
        @limit = params[:limit]
        @min_delay = params[:min_delay]
        @max_delay = params[:max_delay]

        # Shared state
        @status = :running
        @gather_stack = []
        @write_stack = []

        # Worker state
        @accumulating = {}
        @next_flush = Time.now.to_i + @flush_interval
        @socket = nil

        # Synchronization primitives
        @lock = Mutex.new
        @worker_event = ConditionVariable.new   # Signals worker to wake-up
        @shutdown_event = ConditionVariable.new # Signals close() caller when shutdown is complete

        # The worker thread does all of the data processing and socket writing
        Thread.new do
          worker_loop
        end
      end

      def write(metrics)
        push(@write_stack, Timestamped.new(metrics.clone)) if metrics.is_a? Hash
      end

      def gather(metrics)
        push(@gather_stack, Timestamped.new(metrics.clone)) if metrics.is_a? Hash
      end

      def close(timeout=nil)
        @lock.synchronize do
          case @status
            when :running, :ending
              @status = :ending
              @worker_event.signal
              @shutdown_event.wait(@lock, timeout)
              return @status == :shutdown
            when :shutdown
              return true
            else
              # TODO: error callback
          end
        end
      end


      private

      def push(stack, value)
        pushed = false
        @lock.synchronize do
          if stack.length <= @limit and @status == :running
            stack << value
            pushed = true
            @worker_event.signal
          end
        end
        pushed
      end

      def worker_loop
        loop do
          begin
            writes = nil
            gathers = nil

            @lock.synchronize do
              if @write_stack.empty? and @gather_stack.empty?
                case @status
                  when :running
                    wait_time = @next_flush - Time.now.to_i
                    if wait_time > 0
                      @worker_event.wait(@lock, wait_time)
                    end

                  when :ending, :shutdown
                    flush_accumulating

                    # Try to be nice by closing the socket, but don't fall into a retry loop if it fails
                    socket, @socket = @socket, nil
                    socket.close unless socket.nil?
                    @status = :shutdown
                    @shutdown_event.broadcast
                    Thread.exit
                  else
                    # TODO: Error callback
                end
              end

              # Swap existing stacks with new ones
              writes, @write_stack = @write_stack, []
              gathers, @gather_stack = @gather_stack, []
            end

            process_writes writes
            process_gathers gathers

            # TODO: Use helper method
            now = Time.now.to_i
            if now > @next_flush
              flush_accumulating
            end

          rescue Exception => e
            # TODO: Error callback
          end
        end
      end

      def process_writes(writes)
        writes.each do |timestamped|
          timestamped.value.each_pair do |k, v|
            write_line(k, v, timestamped.time)
          end
        end
      end

      def process_gathers(gathers)
        gathers.each do |timestamped|
          timestamped.value.each_pair do |k, v|
            next if k.nil? or v.nil?
            key = k.to_sym
            if @accumulating.has_key? key
              @accumulating[key] += v
            else
              @accumulating[key] = v
            end
          end
        end
      end

      def flush_accumulating
        now = Time.now.to_i
        @accumulating.each_pair { |k, v| write_line(k, v, now) }
        @accumulating.clear
        @next_flush = now + @flush_interval
      end

      def write_line(key, value, time)
        return unless key.is_a? String or key.is_a? Symbol
        return unless value.is_a? Fixnum
        return unless time.is_a? Fixnum

        sent = false
        failure_delay = @min_delay
        until sent
          begin
            if @socket.nil?
              new_socket
            end
            @socket.send("#{@prefix}#{key} #{value} #{time}\n", 0)
            sent = true

          rescue
            # Protection from network failure
            # TODO: Error callback
            sleep failure_delay
            new_socket
            if failure_delay < @max_delay
              failure_delay += 1
            end
          end
        end
      end

      def new_socket
        case @transport
          when :tcp
            @socket = TCPSocket.new(@host, @port)
          when :udp
            @socket = UDPSocket.new
            @socket.connect(@host, @port)
          else
            # TODO: Error callback
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
