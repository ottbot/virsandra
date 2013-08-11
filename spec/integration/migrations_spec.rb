require 'feature_helper'

describe "Cassandra migrations", integration: true do
  let(:keyspace){ Virsandra::Keyspace.new(TEST_KEYSPACE) }
  let(:options){ {} }
  let(:files){ Dir[File.join(VIRSANDRA_TEST_ROOT, 'fixtures', 'migrations', '*.rb')] }
  let(:migration){ Virsandra::Migration.new(files, options) }
  let(:default_tables){ ['schema_migrations'] }

  describe "migrating up" do
    context "only new files" do
      it "orders all files and migrates up each of them" do
        keyspace.tables.should be_empty
        migration.migrate_up
        keyspace.tables.should eq(default_tables + ['table_one', 'table_three', 'table_two'])
      end
    end

    context "with already migrated files" do
      before do
        Virsandra::Migration.new(files, version: "20130809143055").migrate_up
      end

      it "orders all files and migrates up only those that have not yet been migrated" do
        keyspace.tables.should eq(default_tables + ["table_one"])
        CreateTableOne.any_instance.should_not_receive(:new)
        migration.migrate_up
        keyspace.tables.should eq(default_tables + ['table_one', 'table_three', 'table_two'])
      end
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