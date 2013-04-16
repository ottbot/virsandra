require 'spec_helper'

describe Virsandra::Connection do
  before { Virsandra.disconnect! }

  let(:connection) { Virsandra::Connection.new(Virsandra)}

  it "raises an exception if settings are invalid" do
    Virsandra.keyspace = nil
    expect { connection }.to raise_error(Virsandra::ConfigurationError)
  end

  it "obtains a db connection" do
    connection.handle.should be_a CassandraCQL::Database
  end

  it "delegates to the cassandra handle" do
    connection.handle.should_receive(:execute)
    connection.execute("SELECT * FROM some_table")
  end

  it "checks if a cassandra connection will respond to a method" do
    connection.should respond_to :execute
  end
end
