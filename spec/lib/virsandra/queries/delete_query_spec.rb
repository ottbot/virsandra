require 'spec_helper'

describe Virsandra::DeleteQuery do
  subject(:query){ described_class.new }

  its(:to_s){ should eq("DELETE") }

  describe "#from" do
    it "deletes from given table" do
      query.from("foo")
      query.to_s.should eq("DELETE FROM foo")
    end

    it "allows to use table as alias method" do
      query.table("foo")
      query.to_s.should eq("DELETE FROM foo")
    end
  end

  describe "#where" do
    it "adds given criteria to query" do
      query.from("foo").where(id: "123")
      query.to_s.should eq("DELETE FROM foo WHERE id = '123'")
    end

    context "called more than once" do
      it "should join all wheres together" do
        query.from("foo").where(id: 1)
        query.where(count: {gt: 4})
        query.to_s.should eq("DELETE FROM foo WHERE id = 1 AND count > 4")
      end
    end
  end
end