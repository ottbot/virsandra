module Virsandra
  class WhereQuery < Query
    OPERATOR_MAPPING = {
      :lt => "<",
      :gt => ">",
      :eq => "=",
      :lt_or_eq => "<=",
      :gt_or_eq => ">=",
      :in => "IN"
    }

    def initialize(clause)
      @clause = clause
    end

    def +(where_query)
      if where_query.is_a?(self.class)
        @clause = [to_s, where_query.to_s.gsub(/^WHERE\s+/, "")].join(" AND ")
      else
        raise InvalidQuery.new("WhereQuery can be mereged only with other WhereQuery")
      end
    end
    alias_method :merge, :+

    private

    def raw_query
      ["WHERE", clause_as_string]
    end

    def clause_as_string
      if @clause.respond_to?(:each_pair)
        result = []
        @clause.each_pair do |field_name, value|
          result << "#{field_name} #{operator_for(value)} #{convert_value(value)}"
        end
        result.join(" AND ")
      else
        @clause.to_s
      end
    end

    def operator_for(value)
      if value.respond_to?(:keys)
        OPERATOR_MAPPING[value.keys.first.to_sym]
      elsif value.respond_to?(:to_a)
        OPERATOR_MAPPING[:in]
      else
        OPERATOR_MAPPING[:eq]
      end
    end

    def convert_value(value)
      if value.respond_to?(:values)
        attribute_value = value.values.first
        if value.keys.first == :in
          convert_value(Array(attribute_value))
        else
          convert_value(attribute_value)
        end
      elsif value.respond_to?(:to_a)
        converted_values = value.to_a.map{|value| CQLValue.convert(value)}
        "(#{converted_values.join(", ")})"
      else
        CQLValue.convert(value)
      end
    end
  end
end