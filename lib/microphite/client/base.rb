# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

module Microphite
  module Client
    class Base
      def initialize(options)
        defaults = {
            prefix: '',            # Prefix every key with this
            flush_interval: 1.0,   # How often to flush gathered metrics
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
        @gather_queue     = Queue.new
        @write_queue      = Queue.new

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

      def write(metrics, &block)
        push_around(@write_queue, metrics, &block)
      end

      def gather(metrics, &block)
        push_around(@gather_queue, metrics, &block)
      end

      def prefix(prefix, &block)
        prefixed = Private::Prefixed.new(self, prefix)
        if block_given?
          block.call(prefixed)
        end
        prefixed
      end

      def time(key, &block)
        if block_given?
          before = now
          result = block.call
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

      private

      def worker_loop
        loop do
          wrap_errors do
            event_wait
            # Unwind and flush gather queue first, since the timestamps are
            # created at flush.  This is more sensitive to delays and fudging
            unwind(@gather_queue).each { |metric| accumulate metric }
            flush_accumulating if should_flush?

            # Handle write queue last, since the timestamps are stored at the
            # time write() is called
            unwind(@write_queue).each { |metric| write_metric metric }
          end
        end
      end

      def push_around(queue, metrics, &block)
        if block_given?
          result = block.call
        else
          result = nil
        end
        push(queue, metrics)
        result
      end

      def push(queue, metrics)
        if metrics.is_a? Hash
          timestamp = now
          cloned = metrics.clone
          @lock.synchronize do
            if queue.length <= @limit and @status == :running
              queue.push [timestamp, cloned]
              @worker_event.signal
            end
          end
        end
      end

      def unwind(queue)
        metrics = []
        until queue.empty?
          tuple = queue.pop
          timestamp, hash = tuple[0], tuple[1]
          wrap_errors do
            hash.each_pair { |k, v| metrics << Metric.new(k, v, timestamp) }
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
        # Capture timestamp first.  If write_metric fails, it might delay before retry
        timestamp = now
        @accumulating.each_pair { |k, v| write_metric(Metric.new(k, v, timestamp)) }
        @accumulating.clear
        @next_flush = now + @flush_interval
      end

      def should_flush?
        now > @next_flush
      end

      def event_wait
        @lock.synchronize do
          if @write_queue.empty? and @gather_queue.empty?
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
        end
      end
    end
  end
end
