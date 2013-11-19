# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

module Microphite
  module Client
    class Dummy < Base
      def initialize(options=nil)
      end

      # Dummy client shouldn't schedule timers
      def every(seconds, &block)
      end
    end
  end
end
