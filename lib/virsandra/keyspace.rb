module Virsandra
  class Keyspace
    class WithReplicationMissedError < ArgumentError ; end

    SYSTEM_KEYSPACE = "system"
    TABLES = {
      columnfamilies: "schema_columnfamilies",
      keyspaces: "schema_keyspaces"
    }

    attr_reader :name

    def initialize(name, config_options = {})
      @config_options = config_options
      @name = name
    end

    def create(options)
      if options[:replication]
        query = Virsandra::CreateKeyspaceQuery.new(name)
        query.with(options)
        system_execute(query.to_s)
      else
        raise WithReplicationMissedError.new(":replication option must be provided")
      end
    end

    def tables
      query = Virsandra::SelectQuery.new("columnfamily_name")
      query.from(TABLES[:columnfamilies]).where(keyspace_name: name)
      system_execute(query.to_s).to_a.map(&:values).flatten.sort
    end

    def create_table(table_name, columns)
      query = Virsandra::CreateTableQuery.new(table_name)
      query.columns(columns)
      execute(query.to_s)
    end

    def exists?
      query = Virsandra::SelectQuery.new
      query.from(TABLES[:keyspaces]).where(keyspace_name: name)
      system_execute(query.to_s).to_a.any?
    end

    def table_exists?(table_name)
      query = Virsandra::SelectQuery.new
      query.from(TABLES[:columnfamilies]).where(keyspace_name: name, columnfamily_name: table_name)
      system_execute(query.to_s).to_a.any?
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