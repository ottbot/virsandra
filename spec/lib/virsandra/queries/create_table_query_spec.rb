require 'spec_helper'

describe Virsandra::CreateTableQuery do
  let(:table_name){ "table_name" }
  subject(:query){ described_class.new(table_name) }

  describe "#to_s" do
    subject{ super().to_s }

    it{ should eq("CREATE TABLE table_name") }
  end

  describe "#columns" do
    subject{ super().columns(["column_one int PRIMARY KEY", "column_two set<text>"]).to_s }

    it {should eq("CREATE TABLE table_name (column_one int PRIMARY KEY, column_two set<text>)")}
  end

  describe "#with" do
    subject{ super().columns(["id int"]).with("CLUSTERING ORDER BY (id DESC)").to_s }

    it {should eq("CREATE TABLE table_name (id int) WITH CLUSTERING ORDER BY (id DESC)") }
  end

  describe "#and" do
    subject{ super().columns(["id int"]).with("COMPACT STORAGE").and("CLUSTERING ORDER BY (id DESC)").to_s }

    it { should eq("CREATE TABLE table_name (id int) WITH COMPACT STORAGE AND CLUSTERING ORDER BY (id DESC)")}

    context "more then one" do
      subject{ query().columns(["id int"]).with("COMPACT STORAGE").and("CLUSTERING ORDER BY (id DESC)").and("other thing").to_s }

      it {should eq("CREATE TABLE table_name (id int) WITH COMPACT STORAGE AND CLUSTERING ORDER BY (id DESC) AND other thing") }
    end

    context "without with" do
      subject{ query.columns(["id int"]).and("COMPACT STORAGE").to_s }

      it{ should eq("CREATE TABLE table_name (id int) WITH COMPACT STORAGE")}
    end
  end
end