# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'spec_helper'

module Microphite
  describe Client::Prefixed do
    include_examples 'microphite client', Client::Prefixed.new(Client::Dummy.new, 'test')
  end
end
