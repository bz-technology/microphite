# Sanity tests for the convenience factories
module Microphite
  describe :client do
    before_block = Proc.new { @client = Microphite::Client::Socket.new(host: 'localhost') }
    after_block = Proc.new {}

    it_should_behave_like 'a microphite client', before_block, after_block
  end

  describe :noop do
    before_block = Proc.new { @client = Microphite::Client::Noop.new(host: 'localhost') }
    after_block = Proc.new {}

    it_should_behave_like 'a microphite client', before_block, after_block
  end
end
