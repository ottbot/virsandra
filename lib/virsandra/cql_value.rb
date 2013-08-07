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
      elsif should_escape?(value)
        "'#{escape(value)}'"
      else
        value.to_s
      end
    end

    private

    def should_escape?(value)
      [String, Symbol, Time, Date].any? do |klass|
        value.is_a?(klass)
      end
    end

    def escape(str)
      str = str.to_s.gsub(/'/,"''")
      str.force_encoding('ASCII-8BIT')
    end

  end
end
