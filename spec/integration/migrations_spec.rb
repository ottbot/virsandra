require 'feature_helper'

describe "Cassandra migrations", integration: true do
  let(:keyspace){ Virsandra::Keyspace.new(TEST_KEYSPACE) }
  let(:files){ Dir[File.join(VIRSANDRA_TEST_ROOT, 'fixtures', 'migrations', '*.rb')] }
  let(:migration){ Virsandra::Migration.new(files) }

  describe "migrating up" do
    context "only new files" do
      it "orders all files and migrates up each of them" do
        keyspace.tables.should be_empty
        migration.migrate_up
        keyspace.tables.should eq(['table_one', 'table_three', 'table_two'])
      end
    end

    context "with files that already been migrated" do
      it "orders all files and migrates up only those that have not yet been migrated"
    end
  end

  describe "migrating down" do
    context "rollback" do
      it "orders all files and migrates down latest one"
    end

    context "given migration identifier" do
      it "orders all files and migrates down to given migration inclusive"
    end
  end
end