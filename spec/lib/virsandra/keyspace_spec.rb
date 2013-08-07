require 'spec_helper'

describe Virsandra::Keyspace do
  let(:name){ "my_keyspace" }
  let(:options){ {} }
  let(:configuration){ double("configuration") }
  let(:connection){ double("connection") }
  subject(:keyspace){ described_class.new(name, options) }

  before do
    Virsandra::Connection.stub(:new).and_return(connection)
  end

  it "initializes keyspace" do
    expect{ keyspace }.not_to raise_error
  end

  describe "#tables" do
    let(:results){ double("results", to_a: [{"columnfamily_name" => "table_2"}, {"columnfamiliy_name" => "table_1"}]) }

    it "returns all tables in given keyspace" do
      Virsandra::Configuration.should_receive(:new).with(keyspace: "system").and_return(configuration)

      Virsandra::SelectQuery.any_instance.should_receive(:from).with('schema_columnfamilies').and_call_original
      Virsandra::SelectQuery.any_instance.should_receive(:where).with(keyspace_name: name).and_call_original
      connection.should_receive(:execute).with(kind_of(String)).and_return(results)

      keyspace.tables.should eq(["table_1", "table_2"])
    end
  end

  describe "#create_table" do
    it "creates table" do
      Virsandra::Configuration.should_receive(:new).with(keyspace: name).and_return(configuration)
      Virsandra::Connection.should_receive(:new).with(configuration).and_return(connection)

      Virsandra::CreateTableQuery.should_receive(:new).with("my_table").and_call_original
      Virsandra::CreateTableQuery.any_instance.should_receive(:columns).with(["column_one int", "column_two text"])
      connection.should_receive(:execute).with(kind_of(String)).and_return(nil)

      keyspace.create_table("my_table", ["column_one int", "column_two text"])
    end
  end
end