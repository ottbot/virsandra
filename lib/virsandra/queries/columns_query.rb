module Virsandra
  class ColumnsQuery < Query

    def initialize
      @columns = []
    end

    def add(column)
      @columns << column
      self
    end

    private

    def raw_query
      [@columns.join(", ")]
    end
  end
end