module Virsandra
  class AddQuery < Query
    def initialize(column_name, column_type = nil)
      @column_name = column_name
      @column_type = column_type.to_s.empty? ? "varchar" : column_type
    end

    def to_s
      validate
      super
    end

    private

    def raw_query
      ["ADD", @column_name, @column_type]
    end

    def validate
      if @column_name.to_s.empty?
        raise InvalidQuery.new("You must specify column name")
      end
    end
  end
end