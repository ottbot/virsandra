require 'spec_helper'

describe Virsandra::SelectQuery do
  let(:columns){ nil }
  let(:skip_validation){ true }
  let(:query){ described_class.new(columns, skip_validation) }
  subject{ query }

  it "uses * as default columns" do
    subject.to_s.should eq("SELECT *")
  end

  context "empty array given as columns" do
    let(:columns){ [] }
    it "uses * as default columns" do
      subject.to_s.should eq("SELECT *")
    end
  end

  context "when columns are given" do
    subject{ super().to_s }

    let(:columns){ "id, date" }

    it{ should eq("SELECT id, date")}

    context "when columns are array" do
      let(:columns){ ['id', 'date'] }

      it{ should eq("SELECT id, date")}
    end
  end

  describe "#from" do
    subject{ super().from("foo").to_s }

    it{ should eq("SELECT * FROM foo")}
  end

  describe "#where" do
    subject{ super().from("foo").where(id: 1).to_s }

    it{ should eq("SELECT * FROM foo WHERE id = 1")}

    context "called more than once" do
      it "should join all wheres together" do
        query.from("foo").where(id: 1)
        query.where(count: {gt: 4})
        query.to_s.should eq("SELECT * FROM foo WHERE id = 1 AND count > 4")
      end
    end
  end

  describe "#order" do
    subject{ super().from("foo").order(date: "asc").to_s }

    it{ should eq("SELECT * FROM foo ORDER BY date ASC")}
  end

  describe "#limit" do
    subject{ super().from("foo").limit(3).to_s }

    it{ should eq("SELECT * FROM foo LIMIT 3")}

    context "when called more than once" do
      it "uses only last one" do
        query.from("foo").limit(1)
        query.limit(4)
        query.to_s.should eq("SELECT * FROM foo LIMIT 4")
      end
    end
  end

  describe "#reset" do
    subject{ super().from("foo").where(id: 1) }

    it "should reset query" do
      subject.to_s.should eq("SELECT * FROM foo WHERE id = 1")
      subject.reset
      subject.where(date: "2011-11-11")
      subject.to_s.should eq("SELECT * FROM foo WHERE date = '2011-11-11'")
    end
  end

  describe "#to_s" do
    let(:skip_validation){ false }
    it "should validate from existence" do
      expect{ query.to_s }.to raise_error(Virsandra::InvalidQuery, "You must set from")
    end
  end

  describe "#allow_filtering!" do
    subject{ super().from("foo").where(id: 1).allow_filtering!.to_s }

    it{ should eq("SELECT * FROM foo WHERE id = 1 ALLOW FILTERING")}
  end

  describe "#deny_filtering!" do
    subject{ super().from("foo").where(id: 1) }

    it "should remove allow filtering clause" do
      subject.allow_filtering!
      subject.to_s.should eq("SELECT * FROM foo WHERE id = 1 ALLOW FILTERING")
      subject.deny_filtering!
      subject.to_s.should eq("SELECT * FROM foo WHERE id = 1")
    end
  end
end