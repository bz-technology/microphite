module Microphite
  class Metric
    attr_reader :key, :value, :time

    def initialize(key, value, time=nil)
      raise(ArgumentError, 'key cannot be nil') if key.nil?
      raise(ArgumentError, 'value cannot be nil') if value.nil?

      @key = key.to_s
      @value = to_f! value
      if time.nil?
        @time = Time.now.to_f
      else
        @time = to_f! time
      end

      raise(ArgumentError, "invalid key: #{key}") if @key.empty?
      raise(ArgumentError, "invaild value: #{value} ") if @value.nil?
      raise(ArgumentError, "invalue time: #{time}") if @time.nil?
    end

    private

    def to_f!(value)
      begin
        Float(value)
      rescue ArgumentError
        nil
      end
    end
  end
end
