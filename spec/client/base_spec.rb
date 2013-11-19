# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'spec_helper'

module Microphite
  describe Client::Base do

    describe :prefix do
      it 'should prefix writes' do
        prefix = 'test.'
        mock_client = double('client')
        prefixed_client = Client::Base::Prefixed.new(mock_client, prefix)
        original_arg = {:key1 => 1, 'key2' => 2}

        expect(mock_client).to receive(:write) do |prefixed_arg|
          expect(prefixed_arg.length).to eq original_arg.length
          original_arg.each_pair do |k, v|
            pa = prefixed_arg
            mutated_key = prefix + k.to_s
            mutated_value = prefixed_arg[mutated_key]
            expect(mutated_value).to eq v
          end
        end

        prefixed_client.write(original_arg)
      end

      it 'should prefix gathers' do
        prefix = 'test.'
        mock_client = double('client')
        prefixed_client = Client::Base::Prefixed.new(mock_client, prefix)
        original_arg = {:key1 => 1, 'key2' => 2}

        expect(mock_client).to receive(:gather) do |prefixed_arg|
          expect(prefixed_arg.length).to eq original_arg.length
          original_arg.each_pair do |k, v|
            pa = prefixed_arg
            mutated_key = prefix + k.to_s
            mutated_value = prefixed_arg[mutated_key]
            expect(mutated_value).to eq v
          end
        end

        prefixed_client.gather(original_arg)
      end
    end
  end
end
