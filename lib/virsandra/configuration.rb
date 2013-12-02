module Virsandra
  class Configuration
    OPTIONS = [
      :consistency,
      :keyspace,
      :servers,
      :credentials,
    ].freeze

    DEFAULT_OPTION_VALUES = {
      servers: "127.0.0.1",
      consistency: :quorum,
      credentials: {}
    }.freeze

    attr_accessor *OPTIONS

    def initialize(options = {})
      reset!
      use_options(options || {})
      accept_changes
    end

    def reset!
      use_options(DEFAULT_OPTION_VALUES)
    end

    def validate!
      unless [servers, keyspace].all?
        raise ConfigurationError.new("A keyspace and server must be defined")
      end
    end

    def accept_changes
      @old_hash = hash
    end

    def to_hash
      OPTIONS.each_with_object({}) do |attr, settings|
        settings[attr] = send(attr)
      end
    end

    def changed?
      hash != @old_hash
    end

    def hash
      to_hash.hash
    end

    private

    def use_options(options)
      options.each do |key, value|
        if OPTIONS.include?(key)
          send(:"#{key}=", value)
        end
      end
    end
  end

end
