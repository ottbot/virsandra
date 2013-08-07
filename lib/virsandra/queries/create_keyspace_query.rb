module Virsandra
  class CreateKeyspaceQuery < Query
    def initialize(name)
      @keyspace = KeyspaceQuery.new("CREATE", name)
      @attributes = {}
    end

    def to_s
      validate
      super
    end

    def with(attributes)
      @attributes = attributes || {}
      self
    end

    def and(attributes)
      @attributes.merge!(attributes)
      self
    end

    private

    def validate
      if @attributes[:replication].to_s.empty?
        raise InvalidQuery.new("Replication strategy is mandatory")
      end
    end

    def raw_query
      [@keyspace, "WITH", attributes_as_string]
    end

    def attributes_as_string
      results = []
      @attributes.each do |attribute, value|
        results << "#{attribute} = #{CQLValue.convert(value)}"
      end
      results.join(" AND ")
    end
  end
end