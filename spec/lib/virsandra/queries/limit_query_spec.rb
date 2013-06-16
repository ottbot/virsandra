require 'spec_helper'

describe Virsandra::LimitQuery do
  let(:number){ 4 }
  subject{ described_class.new(number) }

  describe "#to_s" do
    subject{ super().to_s }

    it{ should eq("LIMIT 4")}

    context "when number is less than 1" do
      let(:number){ 0 }

      it "should raise error" do
        expect{ subject }.to raise_error(Virsandra::InvalidQuery, "Limit must be positive number")
      end
    end
  end
end