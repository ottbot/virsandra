module Virsandra
  class Connection

    extend Forwardable

    attr_reader :handle, :options

    def initialize(options)
      options.validate!
      @options = options.to_hash

      connect!
    end

    def connect!
      @handle = Cql::Client.connect(hosts: @options[:servers])
      @handle.use(@options[:keyspace])
      @handle
    end

    def disconnect!
      @handle.close
    end

    # Delegate to CassandraCQL::Database handle
    def method_missing(method, *args, &block)
      return super unless @handle.respond_to?(method)
      @handle.send(method, *args, &block)
    end

    def respond_to?(method, include_private=false)
      @handle.respond_to?(method, include_private) || super(method, include_private)
    end

  end
end
