require 'spec_helper'

describe Virsandra::TableQuery do
  describe "#to_s" do
    it "return given table name" do
      described_class.new("FROM", "foo").to_s.should eq("FROM foo")
    end

    it "return empty string when nil given" do
      described_class.new("FROM",nil).to_s.should eq("")
    end
  end
end