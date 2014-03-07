require 'spec_helper'

describe Virsandra do
  let(:config){ double("config", :changed? => false, :accept_changes => true) }
  let(:connection){ double("connection") }
  subject{ described_class }

  before do
    described_class::Connection.stub(new: connection)
    described_class::Configuration.stub(new: config)
    described_class.disconnect!
    described_class.reset_configuration!
  end

  after do
    described_class::Connection.unstub(:new)
    described_class::Configuration.unstub(:new)
    described_class.disconnect!
    described_class.reset_configuration!
  end

  describe "#execute" do
    it "should be delegated to connection" do
      connection.should_receive(:execute).with("query", "consistency")
      described_class.execute("query", "consistency")
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

    context "when configuration defined globaly" do
      it "uses global configuration when there is no defined for thread"
    end

    context "when configuration defined for each thread" do
      it "should have configuration for every thread" do
        described_class::Configuration.should_receive(:new).twice
        threads = []
        threads << Thread.new{ described_class.configuration }
        threads << Thread.new{ described_class.configuration }
        threads.map(&:join)
      end
    end
  end

  describe "#configure" do
    it "should yield to block if block given" do
      expect{|b| described_class.configure(&b) }.to yield_with_args(config)
    end
  end

  describe "delegation to configuration" do
    [:keyspace, :servers, :consistency, :reset!].each do |method_name|
      it "should deletege #{method_name} to configuration" do
        config.should_receive(method_name).any_number_of_times.and_return("value")
        described_class.send(method_name).should eq("value")
      end
    end

    [:keyspace=, :servers=, :consistency=].each do |method_name|
      it "should deletege #{method_name} to configuration" do
        config.should_receive(method_name).with("value").any_number_of_times
        described_class.send(method_name, "value")
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

  describe "#reset_configuration!" do
    it "should reset configuration" do
      described_class::Configuration.should_receive(:new).twice
      described_class.configuration
      described_class.reset_configuration!
      described_class.configuration
    end
  end


end
