require 'spec_helper'

describe Virsandra::InsertQuery do
  subject(:query){ described_class.new }

  describe "#into" do
    subject{ super().into("foo") }

    it "should raise error when values are missing" do
      expect{ subject.to_s }.to raise_error(Virsandra::InvalidQuery, "You must set values")
    end
  end

  describe "#values" do
    subject{ super().values(column_name: "name") }

    it "should raise error when into is missing" do
      expect{ subject.to_s }.to raise_error(Virsandra::InvalidQuery, "You must set into")
    end
  end

  describe "#to_s" do
    context "when into is missing" do
      it "should raise error when into is missing" do
        expect{ query.to_s }.to raise_error(Virsandra::InvalidQuery, "You must set into")
      end
    end

    context "when into and values are set" do
      subject{ super().into("foo").values(id: 1, date: '2011-11-11').to_s }

      it{ should eq("INSERT INTO foo (id, date) VALUES (1, '2011-11-11')") }
    end
  end

end