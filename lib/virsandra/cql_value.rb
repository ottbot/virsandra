module Virsandra
  class CQLValue

    def self.convert(val)
      new(val).to_cql
    end

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_cql
      if value.respond_to?(:to_guid)
        value.to_guid
      elsif is_number?(value)
        value.to_s
      else
        "'#{escape(value)}'"
      end
    end

    private

    def is_number?(value)
      value.is_a?(Numeric)
    end

    def escape(str)
      str = str.to_s.gsub(/'/,"''")
      str.force_encoding('ASCII-8BIT')
    end

  end
end
