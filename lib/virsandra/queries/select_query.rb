module Virsandra
  class SelectQuery < Query
    def initialize(columns = nil, skip_validation = false)
      @columns = columns
      @skip_validation = skip_validation
    end

    def from(table)
      @from = TableQuery.new("FROM", table)
      self
    end

    def where(clause)
      unless @where
        @where = WhereQuery.new(clause)
      else
        @where += WhereQuery.new(clause)
      end
      self
    end

    def order(columns)
      @order = OrderQuery.new(columns)
      self
    end

    def limit(number)
      @limit = LimitQuery.new(number)
      self
    end

    def reset
      @where, @order, @limit = nil
    end

    def to_s
      validate
      super
    end

    private

    def raw_query
      ["SELECT", columns_as_string, @from, @where, @order, @limit]
    end

    def columns_as_string
      converted_columns = if @columns.respond_to?(:join)
        @columns.join(", ")
      else
        @columns.to_s
      end
      converted_columns.empty? ? "*" : converted_columns
    end

    def validate
      if !@skip_validation && @from.to_s.empty?
        raise InvalidQuery.new("You must set from")
      end
    end
  end
end