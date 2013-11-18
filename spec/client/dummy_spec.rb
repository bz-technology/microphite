# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'spec_helper'

describe Microphite::Client::Dummy do
  include_examples 'microphite client'

  let(:client) { Microphite::Client::Dummy.new }
end
