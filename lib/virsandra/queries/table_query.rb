module Virsandra
  class TableQuery < Query
    def initialize(keyword, table_name)
      @table_name, @keyword = table_name, keyword
    end

    private

    def raw_query
      [@table_name.to_s.empty? ? "" : @keyword, @table_name]
    end
  end
end