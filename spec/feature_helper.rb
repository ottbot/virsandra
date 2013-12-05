require 'spec_helper'

module IntegrationTestHelper
  def create_keyspace
    Virsandra.keyspace = 'system'
    Virsandra.username = TEST_USERNAME
    Virsandra.password = TEST_PASSWORD
    Virsandra.execute("CREATE KEYSPACE #{TEST_KEYSPACE} WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1}")
    Virsandra.reset!
  end

  def create_companies_table
    cql = <<-CQL
       CREATE TABLE companies (
          id uuid,
          name text,
          score int,
          founder text,
          founded int,
          PRIMARY KEY (id, score))
    CQL
    Virsandra.keyspace = TEST_KEYSPACE
    Virsandra.execute(cql)
  end

  def drop_keyspace
    Virsandra.reset!
    Virsandra.keyspace = 'system'
    Virsandra.execute("DROP KEYSPACE #{TEST_KEYSPACE}")
  end

  def build_up
    begin
      create_keyspace
    rescue Cql::QueryError
      drop_keyspace

      if defined?(retried)
        raise $!
      else
        retried = true
        retry
      end
    end
  end
end


RSpec.configure do |config|

  config.include(IntegrationTestHelper)

  config.before do
    if example.metadata[:integration]
      build_up
      Virsandra.reset!
      Virsandra.keyspace = TEST_KEYSPACE
    end
  end
end