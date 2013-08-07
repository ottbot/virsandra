module Virsandra
  class CQLValue

    def self.convert(val)
      new(val).to_cql
    end

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_cql(given_value = nil)
      value_to_convert = given_value || value

      if value_to_convert.is_a?(Hash)
        convert_hash(value_to_convert)
      elsif value_to_convert.respond_to?(:to_guid)
        convert_uuid(value_to_convert)
      elsif is_number?(value_to_convert)
        convert_object(value_to_convert)
      else
        convert_text(value_to_convert)
      end
    end

    private

    def is_number?(value)
      value.is_a?(Numeric)
    end

    def convert_uuid(given_value = nil)
      (given_value || value).to_guid
    end

    def convert_hash(given_value)
      results = []
      given_value.each do |h_key, h_value|
        results << [to_cql(h_key), to_cql(h_value)].join(": ")
      end
      "{ #{results.join(", ")} }"
    end

    def convert_text(given_value)
      "'#{escape(given_value)}'"
    end

    def convert_object(given_value)
      (given_value ).to_s
    end

    def escape(str)
      str = str.to_s.gsub(/'/,"''")
      str.force_encoding('ASCII-8BIT')
    end

  end
end
