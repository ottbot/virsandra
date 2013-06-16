module Virsandra
  class InvalidQuery < Exception; end

  class Query

    attr_reader :row
    attr_accessor :table, :statement

    class << self

      def select(*fields)
        SelectQuery.new(fields)
      end

      def insert
        InsertQuery.new
      end

      def delete
        DeleteQuery.new
      end

      def alter
        AlterQuery.new
      end
    end

    def to_s
      raw_query.map{|query_part| query_part.to_s }.reject(&:empty?).join(" ")
    end

    def from *args
      raise InvalidQuery.new("From, table or into clause not defined for #{self.class}")
    end
    alias_method :table, :from
    alias_method :into, :from

    def where *args
      raise InvalidQuery.new("Where clause not defined for #{self.class}")
    end

    def order *args
      raise InvalidQuery.new("Order clause not defined for #{self.class}")
    end

    def limit *args
      raise InvalidQuery.new("Limit clause not defined for #{self.class}")
    end

    def add *args
      raise InvalidQuery.new("Add clause not defined for #{self.class}")
    end

    def values *args
      raise InvalidQuery.new("Values clause not defined for #{self.class}")
    end

    def execute
      @row = Virsandra.execute(self.to_s)
    end

    def fetch(statement = nil)
      @raw_query = statement if statement
      execute
      fetch_with_symbolized_keys
    end

    private

    def raw_query
      [@raw_query]
    end

    def fetch_with_symbolized_keys
      if @row
        if row_hash = @row.fetch_hash
          Hash[row_hash.map{|(k,v)| [k.to_sym,v]}]
        else
          {}
        end
      end
    end
  end

end

Dir[File.expand_path('../queries/*_query.rb', __FILE__)].each do |path|
  require path
end
