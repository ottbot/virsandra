require 'spec_helper'

describe Virsandra do
  let(:config){ double("config", :changed? => false, :accept_changes => nil) }
  let(:connection){ double("connection") }
  subject{ described_class }

  before do
    described_class::Connection.stub(new: connection)
    described_class::Configuration.stub(new: config)
    described_class.disconnect!
  end

  after do
    described_class::Connection.unstub(:new)
    described_class::Configuration.unstub(:new)
    described_class.disconnect!
  end

  describe "#execute" do
    it "should be delegated to connection" do
      connection.should_receive(:execute)
      described_class.execute
    end
  end

  describe "#connection" do
    it "should pass configuration to connection" do
      described_class::Connection.should_receive(:new).with(config).once
      described_class.connection
      described_class.connection.should eq(connection)
    end

    it "should create new connection when configuration has been changed" do
      described_class::Connection.should_receive(:new).twice
      described_class.connection
      config.stub(:changed? => true)
      described_class.connection
    end

    it "should have connection for each thread" do
      described_class::Connection.should_receive(:new).twice
      threads = []
      threads << Thread.new{ described_class.connection }
      threads << Thread.new{ described_class.connection }
      threads.map(&:join)
    end
  end


  describe "#configuration" do
    it "returns configuration" do
      described_class.configuration.should eq(config)
    end

    it "should have configuration for every thread" do
      described_class::Configuration.should_receive(:new).twice
      threads = []
      threads << Thread.new{ described_class.configuration }
      threads << Thread.new{ described_class.configuration }
      threads.map(&:join)
    end
  end

  describe "#configure" do
    it "should yield to block if block given" do
      expect{|b| described_class.configure(&b) }.to yield_with_args(config)
    end
  end

  describe "delegation to configuration" do
    [:keyspace, :keyspace=, :servers, :servers=, :consistency, :consistency=, :reset!].each do |method_name|
      it "should deletege #{method_name} to configuration" do
        config.should_receive(method_name).any_number_of_times
        described_class.send(method_name)
      end
    end
  end

  describe "#dissconnect!" do
    it "should dissconnect" do
      described_class.connection
      connection.stub(respond_to?: true)
      connection.should_receive(:disconnect!)
      described_class.disconnect!
    end
  end


end
