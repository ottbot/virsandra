module Virsandra
  class InsertQuery < Query

    def into(table_name)
      @into = TableQuery.new("INTO", table_name)
      self
    end

    def values(values)
      @values = ValuesQuery.new(values)
      self
    end

    def to_s
      validate
      super
    end

    private

    def raw_query
      ["INSERT", @into, @values]
    end

    def validate
      if @into.to_s.empty?
        raise InvalidQuery.new("You must set into")
      end
      if @values.to_s.empty?
        raise InvalidQuery.new("You must set values")
      end
    end
  end
end