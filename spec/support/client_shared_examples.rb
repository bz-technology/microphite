# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

PUBLIC_METHODS = [:write, :gather, :time, :prefix, :close]

shared_examples 'a microphite client' do |before, after|
  before do
    instance_eval &before
  end

  after do
    instance_eval &after
  end

  describe 'interface' do
    PUBLIC_METHODS.each do |method|
      it 'should respond to ' + method.to_s do
        @client.should respond_to method
      end
    end
  end

  describe :write do
    it 'should tolerate valid input' do
      expect { @client.write(key: 0) }.not_to raise_error
      expect { @client.write(key1: 1, key2: 2.5) }.not_to raise_error
    end
  end

  describe :gather do
    it 'should tolerate valid input' do
      expect { @client.gather(key: 0) }.not_to raise_error
      expect { @client.gather(key1: 1, key2: 2.5) }.not_to raise_error
    end
  end

  describe :time do
    it 'should tolerate valid input' do
      expect { @client.time(:key) { 42 } }.not_to raise_error
      expect { @client.time('key') { 42 } }.not_to raise_error
    end

    it 'should return the evaluated block value' do
      expect(@client.time(:key) { 42 }).to eq 42
    end

    it 'should preserve caller self' do
      class Preserve
        def a
        end
        def b(client)
          client.time(:key) { a }
        end
      end
      expect { Preserve.new.b(@client) }.not_to raise_error
    end
  end

  describe :prefix do
    it 'should return a client-like object' do
      prefixed = @client.prefix 'test'
      PUBLIC_METHODS.each do |method|
        prefixed.should respond_to method
      end
    end

    it 'should preserve caller self' do
      class Preserve
        def a
        end
        def b(client)
          client.prefix(:key) { a }
        end
      end
      expect { Preserve.new.b(@client) }.not_to raise_error
    end
  end

  describe :close do
    it 'should not blow up' do
      expect { @client.close }.not_to raise_error
    end
  end
end
