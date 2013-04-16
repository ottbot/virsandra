require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'rspec'
require 'virsandra'


TEST_KEYSPACE = "virtest"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before(:all) do
    Virsandra.keyspace = 'system'
    Virsandra.execute("CREATE KEYSPACE #{TEST_KEYSPACE} WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1}")
    Virsandra.reset!
  end

  config.before(:each) do
    Virsandra.keyspace = TEST_KEYSPACE
  end

  config.after(:all) do
    Virsandra.execute("DROP KEYSPACE #{TEST_KEYSPACE}");
  end
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

end
