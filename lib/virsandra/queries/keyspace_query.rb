module Virsandra
  class KeyspaceQuery < Query
    def initialize(keyword, name)
      @name, @keyword = name, keyword
    end

    private

    def raw_query
      if @name.to_s.empty?
        []
      else
        [@keyword, "KEYSPACE", @name]
      end
    end
  end
end