# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

module Microphite
  module Client
    module Private
      class Timestamped
        attr_accessor :value, :time

        def initialize(value)
          @value = value
          @time = Time.now.to_f
        end
      end
    end
  end
end
