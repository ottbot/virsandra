module Virsandra
  module Migrations
    class Table
      SCHEMA_TABLE = "schema_migrations"

      attr_reader :keyspace

      def initialize(keyspace = nil )
        @keyspace = keyspace || default_keyspace
      end

      def versions
        ensure_table
        query = Virsandra::SelectQuery.new("name").from(SCHEMA_TABLE)
        keyspace.execute(query.to_s).to_a.map(&:values).flatten
      end

      def mark_as_migrated(version)
        ensure_table
        insert = Virsandra::InsertQuery.new
        insert.into(SCHEMA_TABLE).values(name: version)
        keyspace.execute(insert.to_s)
      end

      def ensure_table
        if !@is_table_created && !keyspace.table_exists?(SCHEMA_TABLE)
          keyspace.create_table(SCHEMA_TABLE, ["name text PRIMARY KEY"])
          @is_table_created = true
        end
      end

      private

      def default_keyspace
        Virsandra::Keyspace.new(Virsandra.keyspace)
      end

    end
  end
end