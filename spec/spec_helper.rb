# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

Dir['./spec/support/**/*.rb'].each { |file| require file }
RSpec.configure do |config|
  config.include Helpers
end

require 'simplecov'
SimpleCov.configure do
  add_filter "/spec/"
end

# Coveralls coverage (simplecov-based)
require 'coveralls'
Coveralls.wear!

require 'microphite'
