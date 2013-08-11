require 'spec_helper'

describe Virsandra::Migrations::Table do
  subject{ described_class.new(keyspace) }
  let(:keyspace){ double("keyspace") }
  let(:keyspace_name){ TEST_KEYSPACE }
  let(:results){ double(to_a: [{"name" => "20000101010101"}]) }

  before do
    keyspace.stub(:table_exists? => true)
  end

  it "uses default keyspace when none is given" do
    Virsandra::Keyspace.should_receive(:new).with(Virsandra.keyspace)
    described_class.new
  end

  describe "#versions" do

    it "should return versions" do
      keyspace.should_receive(:execute).with("SELECT name FROM schema_migrations").and_return(results)
      subject.versions.should eq(["20000101010101"])
    end
  end

  it "should create table in system keyspace when one doesn't exist" do
    keyspace.should_receive(:table_exists?).with("schema_migrations").and_return(false)
    keyspace.should_receive(:create_table).with("schema_migrations", ["name text PRIMARY KEY"])
    keyspace.should_receive(:execute).with("SELECT name FROM schema_migrations").and_return(results)
    subject.versions.should eq(["20000101010101"])
  end

  describe "#mark_as_migrated" do
    it "should create record with given version name" do
      keyspace.should_receive(:execute).with("INSERT INTO schema_migrations (name) VALUES ('20000101010101')")
      subject.mark_as_migrated("20000101010101")
    end
  end
end