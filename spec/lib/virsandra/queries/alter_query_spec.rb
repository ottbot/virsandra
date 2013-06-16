require 'spec_helper'

describe Virsandra::AlterQuery do
  let(:skip_validation){ true }
  subject(:query){ described_class.new(skip_validation) }

  describe "#to_s" do
    subject{ super().to_s }

    it{ should eq("ALTER") }

  end

  describe "#table" do
    subject{ super().table("foo").to_s }

    it{ should eq("ALTER TABLE foo")}

    context "with validation" do
      let(:skip_validation){ false }

      it "should raise error when table not specified" do
        expect{ query.to_s }.to raise_error(Virsandra::InvalidQuery, "You must set the table")
      end
    end
  end

  describe "#add" do
    context "without column type" do
      subject{ super().table("foo").add(:new_column).to_s }

      it{ should eq("ALTER TABLE foo ADD new_column varchar")}
    end
  end
end