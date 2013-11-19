# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

module Microphite
  module Client
    class Prefixed < Base
      def initialize(client, prefix)
        @client = client
        @prefix = prefix
      end

      def write(metrics)
        # TODO: Alter all hash keys with prefix
        @client.write(metrics)
      end

      def gather(metrics)
        # TODO: Alter all hash keys with prefix
        @client.write(metrics)
      end

      def prefix(prefix, &block)
        @client.prefix("#{@prefix}.#{prefix}", &block)
      end

      def close(timeout=nil)
        @client.close(timeout)
      end
    end
  end
end
