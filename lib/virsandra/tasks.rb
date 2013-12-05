namespace :virsandra do
  desc "Migration"
  namespace :migrate do
    desc "Migrate Cassandra up"
    task :up do
      require 'virsandra'
      config_options = if ENV["SERVERS"]
        {servers: ENV["SERVERS"]}
      else
        {}
      end
      if ENV['USERNAME'] && ENV['PASSWORD']
        config_options.merge!( credentials: {username: ENV['USERNAME'], password: ENV['PASSWORD']})
      end
      keyspace = if ENV["KEYSPACE"]
        Virsandra::Keyspace.new(ENV["KEYSPACE"], config_options)
      end
      Virsandra::Migration.new(Dir[File.join(Rake.original_dir, "db", "migrations", "*.rb")], keyspace: keyspace).migrate_up
    end

    desc "Migrate down"
    task :down do
      puts "migrating down..."
    end
  end
end