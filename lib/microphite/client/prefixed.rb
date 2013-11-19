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
        @client.write(mutate_hash(metrics))
      end

      def gather(metrics)
        @client.gather(mutate_hash(metrics))
      end

      def prefix(additional, &block)
        @client.prefix("#{@prefix}#{additional}", &block)
      end

      def close(timeout=nil)
        @client.close(timeout)
      end

      private

      def mutate_hash(hash)
        return unless hash.is_a? Hash
        mutated = {}
        hash.each_pair do |k, v|
          next unless k.is_a? String or k.is_a? Symbol
          mutated[@prefix + k.to_s] = v
        end
        mutated
      end
    end
  end
end
