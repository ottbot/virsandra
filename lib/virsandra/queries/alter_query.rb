module Virsandra
  class AlterQuery < Query
    def initialize(skip_validation = false)
      @skip_validation = skip_validation
    end

    def table(table_name)
      @table = TableQuery.new("TABLE", table_name)
      self
    end

    def add(column_name, column_type = nil)
      @add = AddQuery.new(column_name, column_type)
      self
    end

    def to_s
      validate
      super
    end

    private

    def raw_query
      ["ALTER", @table, @add]
    end

    def validate
      if !@skip_validation && @table.to_s.empty?
        raise InvalidQuery.new("You must set the table")
      end
    end
  end
end