require 'virtus'
require 'cql'
require 'forwardable'


require 'virsandra/version'
require 'virsandra/errors'
require 'virsandra/configuration'

module Virsandra

  class << self
    def configuration
      if Thread.current[:virsandra_configuration]
        Thread.current[:virsandra_configuration]
      elsif Thread.main[:virsandra_configuration]
        Thread.main[:virsandra_configuration]
      else
        set_configuration
        configuration
      end
    end

    def configure
      yield configuration
    end

    def connection
      if dirty?
        disconnect!
        Thread.current[:virsandra_connection] = Virsandra::Connection.new(configuration)
        configuration.accept_changes
      end
      Thread.current[:virsandra_connection]
    end

    def connected?
      !!Thread.current[:virsandra_connection]
    end

    def disconnect!
      if Thread.current[:virsandra_connection].respond_to?(:disconnect!)
        Thread.current[:virsandra_connection].disconnect!
      end
      Thread.current[:virsandra_connection] = nil
    end

    def reset!
      configuration.reset!
    end

    def reset_configuration!
      Thread.current[:virsandra_configuration] = nil
    end

    def consistency
      configuration.consistency
    end

    def keyspace
      configuration.keyspace
    end

    def servers
      configuration.servers
    end

    def consistency=(value)
      configuration.consistency = value
    end

    def keyspace=(value)
      configuration.keyspace = value
    end

    def servers=(value)
      configuration.servers = value
    end

    def username=(value)
      configuration.credentials[:username] = value
    end

    def password=(value)
      configuration.credentials[:password] = value
    end

    def execute(query, consistency = nil)
      connection.execute(query, consistency)
    end

    private

    def dirty?
      Thread.current[:virsandra_connection].nil? || configuration.changed?
    end

    def set_configuration
      new_configuration = Virsandra::Configuration.new
      if Thread.current == Thread.main
        Thread.main[:virsandra_configuration] = new_configuration
      else
        Thread.current[:virsandra_configuration] = new_configuration
      end
    end

  end
end



require 'virsandra/connection'
require 'virsandra/cql_value'
require 'virsandra/query'
require 'virsandra/model_query'
require 'virsandra/model'
require 'virsandra/keyspace'
require 'virsandra/migration'
