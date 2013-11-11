require 'virtus'
require 'cql'
require 'forwardable'


require 'virsandra/version'
require 'virsandra/errors'
require 'virsandra/configuration'

module Virsandra

  class << self
    def configuration
      if Thread.current[:configuration]
        Thread.current[:configuration]
      elsif Thread.main[:configuration]
        Thread.main[:configuration]
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
        Thread.current[:connection] = Virsandra::Connection.new(configuration)
        configuration.accept_changes
      end
      Thread.current[:connection]
    end

    def disconnect!
      if Thread.current[:connection].respond_to?(:disconnect!)
        Thread.current[:connection].disconnect!
      end
      Thread.current[:connection] = nil
    end

    def reset!
      configuration.reset!
    end

    def reset_configuration!
      Thread.current[:configuration] = nil
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

    def execute(query)
      connection.execute(query)
    end

    private

    def dirty?
      Thread.current[:connection].nil? || configuration.changed?
    end

    def set_configuration
      new_configuration = Virsandra::Configuration.new
      if Thread.current == Thread.main
        Thread.main[:configuration] = new_configuration
      else
        Thread.current[:configuration] = new_configuration
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
