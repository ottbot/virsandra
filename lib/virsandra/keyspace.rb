module Virsandra
  class Keyspace
    SYSTEM_KEYSPACE = "system"

    attr_reader :name

    def initialize(name, options = {})
      @config_options = options.delete(:configuration) || {}
      @name = name
    end

    def tables
      query = Virsandra::SelectQuery.new("columnfamily_name")
      query.from("schema_columnfamilies").where(keyspace_name: name)
      system_execute(query.to_s).to_a.map(&:values).flatten.sort
    end

    def create_table(table_name, columns)
      query = Virsandra::CreateTableQuery.new(table_name)
      query.columns(columns)
      execute(query.to_s)
    end

    def execute(query)
      connection.execute(query)
    end

    private

    def system_execute(query)
      system_connection.execute(query)
    end

    def system_connection
      @system_connection ||= Virsandra::Connection.new(configuration(keyspace: SYSTEM_KEYSPACE))
    end

    def connection
      @connection ||= Virsandra::Connection.new(configuration(keyspace: name))
    end

    def configuration(options)
      Virsandra::Configuration.new(@config_options.merge(options))
    end
  end
end