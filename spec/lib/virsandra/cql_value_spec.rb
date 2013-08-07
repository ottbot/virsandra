require 'spec_helper'

describe Virsandra::CQLValue do

  subject { Virsandra::CQLValue }

  it "returns plain numbers" do
    subject.convert(10).should == "10"
    subject.convert(10.0).should == "10.0"
    subject.convert(BigDecimal.new("10.0")).should == "0.1E2"
  end

  it "quotes strings" do
    subject.convert("Hello").should == "'Hello'"
  end

  it "escapes strings" do
    subject.convert("It's all good.").should == "'It''s all good.'"
  end

  it "converts UUID to guid" do
    uuid = SimpleUUID::UUID.new
    subject.convert(uuid).should == uuid.to_guid
  end

  it "convert Hash to map" do
    hash = {key1: 'value', key2: 3}
    subject.convert(hash).should == "{ 'key1': 'value', 'key2': 3 }"
  end
end
