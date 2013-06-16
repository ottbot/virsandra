require 'spec_helper'

describe Virsandra::AddQuery do
  let(:column_name){ "new_column" }
  let(:column_type){ nil }
  subject(:query){ described_class.new(column_name, column_type) }

  describe "#to_s" do
    subject{ super().to_s }

    it{ should eq("ADD new_column varchar") }

    context "column type specified" do
      let(:column_type){ "int" }

      it{ should eq("ADD new_column int") }
    end

    context "column name not specified" do
      let(:column_name){ nil }
      it "should raise error" do
        expect{ subject }.to raise_error(Virsandra::InvalidQuery, "You must specify column name")
      end
    end
  end
end