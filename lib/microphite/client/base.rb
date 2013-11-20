# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

module Microphite
  module Client
    class Base
      def initialize(options)
        defaults = {
            prefix: '',            # Prefix every key with this
            flush_interval: 10,    # How often to flush gathered metrics
            limit: 1000000,        # Size limit for gather and write stacks
            error_handler: nil     # Callback block for exceptions (mainly for debug/dev)
        }
        params = defaults.merge(options)

        # Read-only state
        @prefix           = params[:prefix]
        @limit            = params[:limit]
        @flush_interval   = params[:flush_interval]
        @error_handler    = params[:error_handler]

        # Shared state
        @status           = :running
        @gather_stack     = []
        @write_stack      = []

        # Worker state
        @accumulating     = {}
        @next_flush       = now + @flush_interval

        # Synchronization primitives
        @lock             = Mutex.new
        @worker_event     = ConditionVariable.new   # Signals worker to wake-up
        @shutdown_event   = ConditionVariable.new   # Signals close() caller when shutdown is complete

        # The worker thread does all of the data processing and socket writing
        Thread.new do
          wrap_errors do
            startup

            # If startup throws, then worker_loop will never be called (what we want)
            worker_loop
          end
        end
      end

      def write(metrics)
        push(@write_stack, metrics.clone)
      end

      def gather(metrics)
        push(@gather_stack, metrics.clone)
      end

      def prefix(prefix, &block)
        prefixed = Private::Prefixed.new(self, prefix)
        if block_given?
          prefixed.instance_eval &block
        end
        prefixed
      end

      def time(key, &block)
        if block_given?
          before = now
          result = instance_eval &block
          after = now
          elapsed = after - before
          gather(key => elapsed)
          result
        end
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
              error(AssertionError.new("Invalid status: #{@status}"))
          end
        end
      end

      protected

      # Lifecycle hook for subclasses
      def startup
      end

      # Lifecycle hook for subclasses
      def shutdown
      end

      def write_metric(metric)
        raise(AssertionError, 'write_metric must be implemented in subclasses')
      end

      private

      def worker_loop
        loop do
          wrap_errors do
            writes = nil
            gathers = nil

            @lock.synchronize do
              if @write_stack.empty? and @gather_stack.empty?
                case @status
                  when :running
                    wait_time = @next_flush - now
                    if wait_time > 0
                      @worker_event.wait(@lock, wait_time)
                    end

                  when :ending, :shutdown
                    flush_accumulating
                    wrap_errors do
                      shutdown
                    end
                    @status = :shutdown
                    @shutdown_event.broadcast
                    Thread.exit

                  else
                    error(AssertionError.new("Invalid status: #{@status}"))
                    Thread.exit
                end
              end

              # Swap existing stacks with new ones
              writes, @write_stack = @write_stack, []
              gathers, @gather_stack = @gather_stack, []
            end

            unwind(writes).each { |m| write_metric m }
            unwind(gathers).each { |m| accumulate m }
            flush_accumulating if should_flush?
          end
        end
      end

      def push(stack, value)
        timestamp = now
        pushed = false
        @lock.synchronize do
          if stack.length <= @limit and @status == :running
            stack << timestamp << value
            pushed = true
            @worker_event.signal
          end
        end
        pushed
      end

      def unwind(stack)
        metrics = []
        until stack.empty?
          value = stack.pop
          timestamp = stack.pop
          wrap_errors do
            case value
              when Hash
                value.each_pair { |k, v| metrics << Metric.new(k, v, timestamp) }
              when Array
                metrics.each do |m|
                  if m.is_a? Metric
                    metrics << m
                  else
                    error(AssertionError.new("Unhandled metric type: #{value.class}"))
                  end
                end
              when Metric
                metrics << value
              else
                error(AssertionError.new("Unhandled metric type: #{value.class}"))
            end
          end
        end
        metrics
      end

      def accumulate(metric)
        if @accumulating.has_key? metric.key
          @accumulating[metric.key] += metric.value
        else
          @accumulating[metric.key] = metric.value
        end
      end

      def flush_accumulating
        @accumulating.each_pair { |k, v| write_metric(Metric.new(k, v, now)) }
        @accumulating.clear
        @next_flush = now + @flush_interval
      end

      def should_flush?
        now > @next_flush
      end

      def now
        Time.now.to_f
      end

      def error(error)
        if @error_handler.is_a? Proc
          @error_handler.call(error)
        end
      end

      def wrap_errors(&block)
        begin
          block.call
        rescue Exception => e
          error(e)
        end
      end
    end
  end
end
