require_relative 'microphite/client'
require_relative 'microphite/exceptions'
require_relative 'microphite/metric'
require_relative 'microphite/version'

module Microphite
  def self.client(options)
    Client::Socket.new(options)
  end

  def self.noop(options=nil)
    Client::Noop.new(options)
  end
end
