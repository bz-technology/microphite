# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'microphite'
require 'socket'

# Coveralls support
require 'coveralls'
Coveralls.wear!

Dir['./spec/support/**/*.rb'].each { |file| require file }


RSpec.configure do |config|
  config.include Helpers
end
