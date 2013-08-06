require 'spec_helper'

describe Virsandra::Configuration do
  subject(:config){ described_class.new(given_options) }
  let(:given_options){ {} }

  its(:servers){ should eq("127.0.0.1") }
  its(:consistency){ should eq(:quorum) }
  its(:keyspace){ should be_nil }

  it "uses given values over default ones" do
    described_class.new(consistency: :one).consistency.should eq(:one)
  end

  describe "validate!" do
    context "no keyspace" do
      it "should raise an error" do
        expect{ config.validate! }.to raise_error(Virsandra::ConfigurationError)
      end
    end

    context "no servers" do
      let(:given_options){ {servers: nil} }

      it "should raise an error" do
        expect{ config.validate! }.to raise_error(Virsandra::ConfigurationError)
      end
    end
  end

  describe "#reset!" do
    let(:given_options){ {keyspace: :my_keyspace} }

    it "reset options to default ones" do
      config.reset!
      config.keyspace.should == :my_keyspace
    end
  end

  describe "to_hash" do
    it "returns all options as a hash" do
      config.to_hash.should eq({
        consistency: :quorum,
        keyspace: nil,
        servers: "127.0.0.1"
      })
    end
  end

  describe "changed?" do
    it "should be changed when option attribute value changes" do
      config.changed?.should be_false
      config.keyspace = :other
      config.changed?.should be_true
    end

    it "stops being changed when changes are accepted" do
      config.changed?.should be_false
      config.keyspace = :other
      config.changed?.should be_true
      config.accept_changes
      config.changed?.should be_false
    end
  end

end