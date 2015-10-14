module Virsandra
  class ModelQuery

    def initialize(model)
      @model = model
    end

    def find_by_key
      return {} unless @model.valid?
      query = Query.select.from(@model.table).where(@model.key)
      query.fetch
    end

    def save
      query = Query.insert.into(@model.table).values(@model.attributes)
      query.fetch
    end

    def delete
      query = Query.delete.from(@model.table).where(@model.key)
      query.fetch
    end

    def where(params)
      query = Query.select.from(@model.table)

      unless params.empty?
        raise ArgumentError.new("Invalid search terms") unless valid_search_params?(params)
        query.where(params)
      end

      query_enumerator(query)
    end

    private

    def valid_search_params?(params)
      params.keys.all? { |k| @model.column_names.include?(k.to_sym) }
    end

    def query_enumerator(query)
      Enumerator.new do |yielder|
        rows = query.execute
        Array(rows).each do |row|
          record = @model.new(row.to_hash)
          yielder.yield record
        end
      end
    end

  end
end
