require 'spec_helper'

describe Virsandra::Keyspace do
  let(:name){ "my_keyspace" }
  let(:config_options){ {} }
  let(:configuration){ double("configuration") }
  let(:connection){ double("connection") }
  subject(:keyspace){ described_class.new(name, config_options) }

  before do
    Virsandra::Connection.stub(:new).and_return(connection)
    Virsandra::Configuration.stub(:new).and_return(configuration)
  end

  it "initializes keyspace" do
    expect{ keyspace }.not_to raise_error
  end

  describe "#exists?" do

    context "exist" do
      let(:results){ double("results", to_a: [double]) }

      it "returns true" do
        Virsandra::Configuration.should_receive(:new).with(keyspace: "system").and_return(configuration)
        connection.should_receive(:execute).with("SELECT * FROM schema_keyspaces WHERE keyspace_name = '#{name}'").and_return(results)
        keyspace.exists?.should be_true
      end
    end

    context "doesn't exit" do
      let(:results){ double("results", to_a: []) }

      it "returns false" do
        Virsandra::Configuration.should_receive(:new).with(keyspace: "system").and_return(configuration)
        connection.should_receive(:execute).with("SELECT * FROM schema_keyspaces WHERE keyspace_name = '#{name}'").and_return(results)
        keyspace.exists?.should be_false
      end
    end
  end

  describe "#create" do
    it "should raise an error when no with replication options given" do
      expect{ keyspace.create({}) }.to raise_error(Virsandra::Keyspace::WithReplicationMissedError)
    end

    it 'create keyspace with given replication options' do
      connection.should_receive(:execute).with("CREATE KEYSPACE #{name} WITH replication = { 'class': 'SimpleStrategy', 'replication_factor': 1 } AND durable_writes = true")
      keyspace.create(replication: {class: "SimpleStrategy", replication_factor: 1}, durable_writes: true)
    end
  end

  describe "#tables" do
    let(:results){ double("results", to_a: [{"columnfamily_name" => "table_2"}, {"columnfamiliy_name" => "table_1"}]) }

    it "returns all tables in given keyspace" do
      Virsandra::Configuration.should_receive(:new).with(keyspace: "system").and_return(configuration)
      connection.should_receive(:execute)
        .with("SELECT columnfamily_name FROM schema_columnfamilies WHERE keyspace_name = '#{name}'")
        .and_return(results)

      keyspace.tables.should eq(["table_1", "table_2"])
    end
  end

  describe "#create_table" do
    it "creates table" do
      Virsandra::Configuration.should_receive(:new).with(keyspace: name).and_return(configuration)
      Virsandra::Connection.should_receive(:new).with(configuration).and_return(connection)
      connection.should_receive(:execute).with("CREATE TABLE my_table (column_one int, column_two text)").and_return(nil)

      keyspace.create_table("my_table", ["column_one int", "column_two text"])
    end
  end
end