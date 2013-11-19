# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

PUBLIC_METHODS = [:write, :gather, :prefix, :every, :shutdown]

shared_examples 'microphite client' do |client|
  describe 'interface' do
    PUBLIC_METHODS.each do |method|
      it 'should respond to ' + method.to_s do
        client.should respond_to method
      end
    end
  end

  describe :write do
    it 'should tolerate valid input' do
      expect { client.write(key: '0') }.not_to raise_error
      expect { client.write(key1: '1', key2: '2') }.not_to raise_error
    end

    it 'should tolerate garbage input' do
      expect { client.write(nil) }.not_to raise_error
      expect { client.write('string') }.not_to raise_error
      expect { client.write(0) }.not_to raise_error
      expect { client.write(key: 'string') }.not_to raise_error
      expect { client.write(key: nil) }.not_to raise_error
    end
  end

  describe :gather do
    it 'should tolerate valid input' do
      expect { client.gather(key: '0') }.not_to raise_error
      expect { client.gather(key1: '1', key2: '2') }.not_to raise_error
    end

    it 'should tolerate garbage input' do
      expect { client.gather(nil) }.not_to raise_error
      expect { client.gather('string') }.not_to raise_error
      expect { client.gather(0) }.not_to raise_error
      expect { client.gather(key: 'string') }.not_to raise_error
      expect { client.gather(key: nil) }.not_to raise_error
    end
  end

  describe :prefix do
    it 'should return a client-like object' do
      prefixed = client.prefix 'test'
      PUBLIC_METHODS.each do |method|
        prefixed.should respond_to method
      end
    end
  end

  describe :every do
    it 'should not blow up' do
      expect { client.every(1) {true} }.not_to raise_error
    end
  end

  describe :shutdown do
    it 'should not blow up' do
      expect { client.shutdown }.not_to raise_error
    end
  end
end
