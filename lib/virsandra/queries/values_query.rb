module Virsandra
  class ValuesQuery < Query
    def initialize(values)
      @values = values
    end

    private

    def raw_query
      [values_to_string]
    end

    def values_to_string
      if @values.respond_to?(:each_pair)
        if values_str = values_as_string and !values_str.empty?
          "(#{columns_as_string}) VALUES (#{values_str})"
        else
          ""
        end
      else
        ""
      end
    end

    def columns_as_string
      columns = []
      @values.each_pair do |key, value|
        columns << key unless value.nil?
      end
      columns.join(", ")
    end

    def values_as_string
      values = []
      @values.each_pair do |key, value|
        values << CQLValue.convert(value) unless value.nil?
      end
      values.join(", ")
    end
  end
end