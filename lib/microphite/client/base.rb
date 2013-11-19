# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

module Microphite
  module Client
    class Base
      def prefix(prefix, &block)
        prefixed = Prefixed.new(self, prefix)
        if block_given?
          prefixed.instance_eval &block
        end
        prefixed
      end

      def write(metrics)
        true
      end

      def gather(metrics)
        true
      end

      def close(timeout=nil)
        true
      end
    end
  end
end
