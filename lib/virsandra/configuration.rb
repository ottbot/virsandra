module Virsandra
  class ConfigurationError < Exception; ; end

  module Configuration

    OPTIONS = [
      :keyspace,
      :servers,
      :consistency,
    ]

    attr_accessor *OPTIONS

    def self.extended(base)
      base.reset!
    end

    def reset!
      self.servers = '127.0.0.1:9160'
      self.consistency = :quorum
      self.keyspace = nil
    end

    def configure
      yield self
    end

    def validate!
      unless [servers, keyspace].all?
        raise ConfigurationError.new("A keyspace and server must be defined")
      end
    end

    def to_hash
      OPTIONS.reduce({}) do |settings, option|
        settings[option] = self.send(option)
        settings
      end
    end

  end
end
