require 'spec_helper'

describe Virsandra::Connection do
  let(:config){ Virsandra::Configuration.new(keyspace: :my_keyspace) }
  let(:handle){ double("handle", use: nil, close: true, ) }
  subject(:connection){ described_class.new(config) }

  before do
    Cql::Client.stub(:connect).and_return(handle)
  end

  its(:config){ should eq(config) }

  context "invalid configuration" do
    it "raises an exception if settings are invalid" do
      config.keyspace = nil
      expect { connection }.to raise_error(Virsandra::ConfigurationError)
    end
  end

  it "obtains a db connection" do
    connection.handle.should eq(handle)
  end

  it "delegates to the cassandra handle" do
    connection.handle.should_receive(:keyspace)
    connection.keyspace
  end

  it "checks if a cassandra connection will respond to a method" do
    handle.stub(:respond_to? => true)
    connection.should respond_to :execute
  end

  it "should disconnect" do
    handle.should_receive(:close)
    connection.disconnect!
  end

  describe "#execute" do
    it "should use configuration consistency when none is given" do
      config.consistency = :one
      handle.should_receive(:execute).with("query", :one)
      connection.execute("query")
    end

    context "cql fails" do
      it "re-connects and tries one more time" do
        handle.should_receive(:execute).and_raise(Cql::NotConnectedError.new("the error"))
        handle.should_receive(:execute).and_return("results")
        connection.execute("query").should eq("results")
      end
    end
  end
end
