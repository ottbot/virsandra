module Virsandra
  class CreateTableQuery < Query

    def initialize(table_name)
      @table = TableQuery.new("CREATE TABLE", table_name)
      @and = []
    end

    def columns(given_columns)
      @columns = ColumnsQuery.new()
      given_columns.each do |given_column|
        @columns.add(given_column)
      end
      self
    end

    def with(value)
      @with = "WITH #{value}"
      self
    end

    def and(value)
      if @with
        @and << value
      else
        with(value)
      end
      self
    end

    private

    def raw_query
      [@table, columns_as_string, @with, and_as_string]
    end

    def columns_as_string
      @columns ? "(#{@columns.to_s})" : ""
    end

    def and_as_string
      (@and.any? ? ([""] + @and).join(" AND ") : "").lstrip
    end
  end
end