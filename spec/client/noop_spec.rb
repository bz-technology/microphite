# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'spec_helper'

module Microphite
  describe Client::Noop do
    before_block = Proc.new { @client = Client::Noop.new }
    after_block = Proc.new {}

    it_should_behave_like 'a microphite client', before_block, after_block
  end
end
