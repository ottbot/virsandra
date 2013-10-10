namespace :virsandra do
  desc "Migration"
  namespace :migrate do
    desc "Migrate Cassandra up"
    task :up do
      require 'virsandra'
      require 'pry'
      keyspace = if ENV["KEYSPACE"]
        Virsandra::Keyspace.new(ENV["KEYSPACE"])
      end
      Virsandra::Migration.new(Dir[File.join(Rake.original_dir, "db", "migrations", "*.rb")], keyspace: keyspace).migrate_up
    end

    desc "Migrate down"
    task :down do
      puts "migrating down..."
    end
  end
end