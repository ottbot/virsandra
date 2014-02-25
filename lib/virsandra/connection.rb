require 'cql/compression/snappy_compressor'
module Virsandra
  class Connection

    extend Forwardable

    attr_reader :handle, :config

    def initialize(config)
      @config = config
      config.validate!
      connect!
    end

    def connect!
      params = {hosts: [@config.servers].flatten,  compressor: Cql::Compression::SnappyCompressor.new}
      if @config.credentials.any?
        params.merge!( credentials: @config.credentials )
      end
      @handle = Cql::Client.connect( params )
      @handle.use(@config.keyspace)
      @handle
    end

    def disconnect!
      @handle.close
    end

    def execute(query, consistency = nil)
      @handle.execute(query, consistency || config.consistency)
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
