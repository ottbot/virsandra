require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'rspec'
require 'virsandra'


TEST_KEYSPACE = "virtest"

def create_keyspace
  Virsandra.keyspace = 'system'
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
    create_companies_table
  rescue CassandraCQL::Error::InvalidRequestException
    drop_keyspace

    if defined?(retried)
      raise $!
    else
      retried = true
      retry
    end
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before(:suite) do
    build_up
  end

  config.before do
    Virsandra.reset!
    Virsandra.keyspace = TEST_KEYSPACE
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

end
