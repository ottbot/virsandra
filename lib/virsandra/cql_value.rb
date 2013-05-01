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
      case value
      when Numeric
        value.to_s
      when SimpleUUID::UUID
        value.to_guid
      else
        "'#{escape(value)}'"
      end
    end

    private

    def escape(str)
      str = str.to_s.gsub(/'/,"''")
      str.force_encoding('ASCII-8BIT')
    end

  end
end
