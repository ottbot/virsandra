require 'spec_helper'


describe Virsandra::KeyspaceQuery do
  describe "#to_s" do
    it "return prefix with given name" do
      described_class.new("CREATE", "foo").to_s.should eq("CREATE KEYSPACE foo")
    end

    it "return empty string when no name given" do
      described_class.new("CREATE",nil).to_s.should eq("")
    end
  end
end