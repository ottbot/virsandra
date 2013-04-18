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
  end
end
