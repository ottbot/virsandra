require 'spec_helper'

describe Virsandra do

  before { Virsandra.disconnect! }

  it "delegates execute to the connection handle" do
    Virsandra.should respond_to :execute
  end

  it "has a connection" do
    Virsandra::Connection.should_receive(:new).with(Virsandra).and_call_original
    Virsandra.connection.should be_a Virsandra::Connection
  end

  it "can be configured via block" do
    Virsandra.configure do |c|
      c.keyspace = 'foo'
    end

    Virsandra.keyspace.should == 'foo'
  end

  it "resets to default settings" do
    Virsandra.keyspace = 'foo'
    Virsandra.reset!
    Virsandra.keyspace.should be_nil
  end

  it "is invalid without a keyspace" do
    Virsandra.keyspace = nil
    expect { Virsandra.validate! }.to raise_error(Virsandra::ConfigurationError)
  end

  it "is invalid without a server" do
    Virsandra.keyspace = 'foo'
    Virsandra.servers = nil
    expect { Virsandra.validate! }.to raise_error(Virsandra::ConfigurationError)
  end

  it "hashifies the settings" do
    Virsandra.reset!

    defaults = {
      servers: '127.0.0.1:9160',
      cql_version: '3.0.0',
      consistency: :quorum,
      thrift_options: {retries: 5, connect_timeout: 1, timeout: 1},
      keyspace: nil
    }

    Virsandra.to_hash.should == defaults
  end

  it "can tell if connection settings are dirty" do
    Virsandra.connection
    Virsandra.keyspace = 'funky'
    Virsandra.should be_dirty
  end

  it "only connects once" do
    Virsandra::Connection.should_receive(:new).once.and_call_original
    Virsandra.connection
    Virsandra.connection
  end

  it "reconnects if dirty" do
    CassandraCQL::Database.stub(:new)

    Virsandra::Connection.should_receive(:new).twice.and_call_original
    Virsandra.connection

    Virsandra.keyspace = 'foo'
    Virsandra.connection
    Virsandra.connection
  end

  it "disconnects cassandra" do
    Virsandra.connection #reestablish conn for the test
    Virsandra.connection.should_receive(:disconnect!)
    Virsandra.disconnect!
  end

end
