module Virsandra
  class DeleteQuery < Query

    def from(table)
      @from = TableQuery.new("FROM" ,table)
      self
    end
    alias_method :table, :from

    def where(clause)
      unless @where
        @where = WhereQuery.new(clause)
      else
        @where += WhereQuery.new(clause)
      end
      self
    end

    private

    def raw_query
      ["DELETE", @from.to_s, @where.to_s]
    end
  end
end