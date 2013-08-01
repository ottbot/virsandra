require "virtus"
require "cql"
require "simple_uuid"

require "virsandra/version"
require "virsandra/configuration"
require "virsandra/connection"
require "virsandra/cql_value"
require "virsandra/query"
require "virsandra/model_query"
require "virsandra/model"

module Virsandra

  extend Configuration

  class << self
    extend Forwardable
    def_delegator :connection, :execute

    def connection
      @connection = Connection.new(self) if dirty?
      @connection
    end

    def dirty?
      return true if @connection.nil?
      @connection.options != self.to_hash
    end

    def disconnect!
      if @connection && @connection.handle
        @connection.disconnect!
      end
      @connection = nil
    end
  end
end
