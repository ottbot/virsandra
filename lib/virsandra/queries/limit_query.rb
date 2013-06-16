module Virsandra
  class LimitQuery < Query
    def initialize(number)
      @number = number
    end

    private

    def raw_query
      if @number.to_i > 0
        ["LIMIT", @number]
      else
        raise InvalidQuery.new("Limit must be positive number")
      end
    end
  end
end