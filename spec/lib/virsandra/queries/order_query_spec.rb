require 'spec_helper'

describe Virsandra::OrderQuery do
  let(:columns){ nil }
  subject{ described_class.new(columns) }

  describe "#to_s" do
    subject{ super().to_s }

    it{ should eq("") }

    context "when columns given as string" do
      let(:columns){ "date DESC" }

      it{ should eq("ORDER BY date DESC")}
    end

    context "when columns given as hash" do
      let(:columns){ {date: :asc, user_id: :asc} }

      it{ should eq("ORDER BY date ASC, user_id ASC")}
    end

    context "when unknown order given" do
      let(:columns){ {data: :bzz} }

      it "raises an error" do
        expect{ subject }.to raise_error(Virsandra::InvalidQuery, "Unknown order bzz")
      end
    end

  end
end