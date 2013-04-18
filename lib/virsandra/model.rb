module Virsandra
  module Model

    include Virtus

    def self.included(base)
      super
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def key
        self.class.key.reduce({}) do |key, col|
          key[col] = attributes[col]
          key
        end
      end

      def table
        self.class.table
      end

      def valid?
        self.class.valid_key?(key)
      end

      def save
        ModelQuery.new(self).save if valid?
      end

      def ==(other)
        other.is_a?(self.class) && attributes == other.attributes
      end
    end

    module ClassMethods
      def table(name = nil)
        @table = name if name
        @table
      end

      def key(*columns)
        @key = columns unless columns.empty?
        @key
      end

      def find(columns)
        raise ArgumentError.new("Invalid key") unless valid_key?(columns)
        load(columns)
      end

      def load(columns)
        record = new(columns)

        row = ModelQuery.new(record).find_by_key
        record.attributes = row.merge(columns)
        record
      end

      def valid_key?(columns)
        return false if columns.length != key.length
        key.all? {|k| !columns[k].nil? }
      end
    end

  end
end
