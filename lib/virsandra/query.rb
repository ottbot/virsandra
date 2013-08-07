module Virsandra
  class InvalidQuery < Exception; end

  class Query
    QUERY_METHODS = [
      :table, :from, :into, :where, :order, :limit, :add, :values, :columns, :and, :with
    ].freeze

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
      invalid_method_call("From, table or into")
    end
    alias_method :table, :from
    alias_method :into, :from

    def method_missing(method_name, *args, &block)
      if QUERY_METHODS.include?(method_name.to_sym)
        invalid_method_call(method_name.to_s.capitalize)
      else
        super
      end
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
      row_hash = @row && @row.first
      return {} unless row_hash

      Hash[row_hash.map{|(k,v)| [k.to_sym,v]}]
    end

    def invalid_method_call(title)
      raise InvalidQuery.new("#{title} clause not defined for #{self.class}")
    end
  end

end

Dir[File.expand_path('../queries/*_query.rb', __FILE__)].each do |path|
  require path
end
