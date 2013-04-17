module Virsandra
  class Query

    class InvalidWhere < Exception; end
    class InvalidValues < Exception; end
    class InvalidAlterAdd < Exception; end
    class TableNotDefined < Exception; end

    attr_reader :row
    attr_accessor :table, :statement

    def self.select(*fields)
      fields << "*" if fields.empty?
      new :select, fields.join(', ')
    end

    def self.insert
      new :insert
    end

    def self.delete
      new :delete
    end

    def self.alter
      new :alter
    end

    def initialize(statement, columns = nil)
      @statement = statement
      @columns = columns

      if statement.is_a? Symbol
        @query = [start_query]
      else
        @query = [@statement]
      end
    end

    def to_s
      @query.join(" ")
    end

    def from(table)
      return self if table.empty?

      @query[1] = @table = table

      self
    end

    alias_method :into,  :from
    alias_method :table, :from


    def where(params)
      prep_clause!
      validate_where!


      clause = params.reduce([]) do |clause, key|
        if key[1]
          key[1] =  prepare_cql_value(key[1])
          clause << key.join(' = ')
        end
      end

      @query << "WHERE"
      @query << clause.join(' AND ')

      self
    end

    def values(params)
      prep_clause!
      validate_insert_values!

      return self if params.empty?

      params.delete_if {|_, val| val.nil? }

      column_names = params.keys

      @query << "(#{column_names.join(', ')})"
      @query << "VALUES"

      values = column_names.map {|col| prepare_cql_value(params[col])}

      @query << "(#{values.join(', ')})"

      self
    end

    def execute
      @row = Virsandra.execute(self.to_s, *@query_arguments)
    end

    def fetch
      execute
      fetch_with_symbolized_keys
    end

    def add(column, type = 'varchar')
      prep_clause!
      validate_alter!

      @query << "ADD"
      @query << column
      @query << type

      self
    end

    private

    def prep_clause!
      @query = @query.take(2)
      @query_arguments = []
      validate_table!
    end

    def validate_where!
      unless [:select, :delete].include? @statement
        raise InvalidWhere.new("Where clause not defined for #{@statement}")
      end
    end

    def validate_insert_values!
      unless [:insert].include? @statement
        raise InvalidValues.new("Values clause not defined for #{@statement}")
      end
    end

    def validate_alter!
      unless [:alter].include? @statement
        raise InvalidAlterAdd.new("Add clause not defined for #{@statement}")
      end
    end

    def validate_table!
      raise TableNotDefined.new("You must set the table") unless @table
    end

    def insert_params
      @columns.to_a.reduce([[],[]]) do |params, column|
        2.times {|i| params[i] << column[i] }
        params
      end.flatten
    end

    def insert_place_holders
      (['?'] * @columns.length).join(', ')
    end

    def start_query
      case @statement
      when :select
        "SELECT #{@columns} FROM"
      when :insert
        "INSERT INTO"
      when :delete
        "DELETE FROM"
      when :alter
        "ALTER TABLE"
      else
        raise ArgumentError, 'Statement not supported'
      end
    end

    def fetch_with_symbolized_keys

      row_hash = @row.fetch_hash if @row

      return {} unless row_hash

      Hash[row_hash.map{|(k,v)| [k.to_sym,v]}]
    end

    def prepare_cql_value(value)
      case value
      when Numeric
        value
      when SimpleUUID::UUID
        value.to_guid
      else
        "'#{escaped_string(value)}'"
      end
    end

    def escaped_string(str)
      str.to_s.gsub(/'/,"''")
    end
  end
end
