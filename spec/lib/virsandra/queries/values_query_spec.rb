require 'spec_helper'

describe Virsandra::ValuesQuery do
  let(:values){ {} }
  subject(:query){ described_class.new(values) }

  describe "#to_s" do
    subject{ super().to_s }

    it{ should eq("") }

    context "when values given" do
      let(:values){ {id: 1, date: '2011-11-11'} }

      it{ should eq("(id, date) VALUES (1, '2011-11-11')")}

      it "should convert each value" do
        Virsandra::CQLValue.should_receive(:convert).twice
        subject
      end
    end

    context "when any value is nil" do
      let(:values){ {id: 1, date: nil} }

      it{ should eq("(id) VALUES (1)")}
    end

    context "when all values are nil" do
      let(:values){ {id: nil, date: nil} }

      it{ should eq("")}
    end
  end
end