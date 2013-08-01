require 'virtus'
require 'cql'
require 'simple_uuid'
require 'forwardable'

require "virsandra/version"
require 'virsandra/errors'
require "virsandra/configuration"

module Virsandra

  class << self
    extend Forwardable
    def_delegator :connection, :execute
    def_delegators :configuration, :reset!, *Virsandra::Configuration::OPTIONS.map{ |method_name| [method_name, :"#{method_name}="] }.flatten

    def configuration
      Thread.current[:configuration] ||= Virsandra::Configuration.new
    end

    def configure
      yield configuration
    end

    def connection
      if dirty?
        Thread.current[:connection] = Virsandra::Connection.new(configuration)
        configuration.accept_changes
      end
      Thread.current[:connection]
    end

    def disconnect!
      if Thread.current[:connection].respond_to?(:dissconnect!)
        Thread.current[:connection].disconnect!
      end
      Thread.current[:connection] = nil
      Thread.current[:configuration] = nil
    end

    private

    def dirty?
      Thread.current[:connection].nil? || configuration.changed?
    end

  end
end



require "virsandra/connection"
require "virsandra/cql_value"
require "virsandra/query"
require "virsandra/model_query"
require "virsandra/model"