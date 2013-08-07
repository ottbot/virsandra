require 'spec_helper'

describe Virsandra::CQLValue do
  subject{ described_class.new(value) }

  describe ".convert" do
    it "should call to_cql on any instance" do
      described_class.should_receive(:new).with(1).and_call_original
      described_class.any_instance.should_receive(:to_cql).and_call_original
      described_class.convert(1)
    end
  end

  describe "#to_cql" do
    subject{ super().to_cql }

    context "String" do
      let(:value){ "Hello" }
      it{ should eq("'Hello'") }
    end

    context "String with single quote" do
      let(:value){ "It's all good." }
      it{ should eq("'It''s all good.'")}
    end

    context "uuid" do
      let(:value){ SimpleUUID::UUID.new }
      it{ should eq(value.to_guid) }
    end

    context "other uuid" do
      let(:value){ double(:class => "FastUuidGenerator", to_s: "0000-0000-000") }
      it{ should eq("0000-0000-000") }
    end

    context "Integer" do
      let(:value){ 10 }
      it{ should eq("10") }
    end

    context "Float" do
      let(:value){ 10.0 }
      it{ should eq("10.0") }
    end

    context "BigDecimal" do
      let(:value){ BigDecimal.new("10.0") }
      it{ should eq("0.1E2") }
    end

    context "Time" do
      let(:value){ Time.new(2011, 5, 29) }
      it{ should eq("'2011-05-29 00:00:00 +0100'")}
    end

    context "Date" do
      let(:value){ Date.new(2011,5,29) }
      it{ should eq("'2011-05-29'") }
    end

    context "Symbol" do
      let(:value){ :value }
      it{ should eq("'value'")}
    end

    context "Array" do
      pending
    end

    context "Set" do
      pending
    end

    context "Hash" do
      pending
    end
  end

end
