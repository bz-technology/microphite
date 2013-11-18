# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

module Microphite
  module Client
    class Dummy
      def initialize(options=nil)
      end

      def write(metrics)
        true
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
    end
  end
end
