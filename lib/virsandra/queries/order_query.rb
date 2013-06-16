module Virsandra
  class OrderQuery < Query
    VALID_ORDERS = ["ASC", "DESC"]

    def initialize(columns)
      @columns = columns
    end

    private

    def raw_query
      [@columns.nil? ? "" : "ORDER BY" ,columns_as_string]
    end

    def columns_as_string
      if @columns.respond_to?(:each_pair)
        result = []
        @columns.each_pair do |column_name, order|
          result << column_as_string(column_name, order)
        end
        result.join(", ")
      else
        @columns.to_s
      end
    end

    def column_as_string(column_name, order)
      normalized_order = order.to_s.upcase
      if VALID_ORDERS.include?(normalized_order)
        "#{column_name} #{normalized_order}"
      else
        raise InvalidQuery.new("Unknown order #{order}")
      end
    end
  end
end