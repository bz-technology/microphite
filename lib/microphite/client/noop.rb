# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

module Microphite
  module Client
    class Noop < Base
      def initialize(options={})
        super(options)
      end

      protected

      def write_metric(metric)
      end
    end
  end
end
