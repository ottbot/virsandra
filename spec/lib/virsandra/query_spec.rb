require 'spec_helper'

describe Virsandra::Query do

  [:from, :table, :into, :where, :order, :limit, :add, :values].each do |method_name|
    it "should raise error when #{method_name} called" do
      expect{ described_class.new.send(method_name) }.to raise_error(Virsandra::InvalidQuery  )
    end
  end

  it "should return empty hash when can't fetch hash from results" do
    Virsandra.stub(:execute => double("row", :fetch_hash => nil))
    described_class.new.fetch.should eq({})
  end

  it "should return empty hash when no results are returned" do
    Virsandra.stub(:execute => nil )
    described_class.new.fetch.should eq({})
  end

  it "adds a from method" do
    q = Virsandra::Query.select.from(:foo)
    q.to_s.should == "SELECT * FROM foo"

    q = Virsandra::Query.insert.into(:foo).values(id: 1)
    q.to_s.should == "INSERT INTO foo (id) VALUES (1)"

    q = Virsandra::Query.delete.from(:foo)
    q.to_s.should == "DELETE FROM foo"

    q = Virsandra::Query.alter.table(:foo)
    q.to_s.should == "ALTER TABLE foo"
  end

  it "can change the table" do
    q = Virsandra::Query.insert.into(:foo).values(id: 1)

    q.into(:bar)
    q.to_s.should == "INSERT INTO bar (id) VALUES (1)"
  end

  it "adds a where clause when appropriate" do
    q = Virsandra::Query.select.from(:foo).where(id: 'Funky', location: 'town')
    q.to_s.should == "SELECT * FROM foo WHERE id = 'Funky' AND location = 'town'"

    q.reset
    q.where(can: "change options")
    q.to_s.should == "SELECT * FROM foo WHERE can = 'change options'"

    uuid = SimpleUUID::UUID.new
    uuid.stub(to_guid: 'i-am-a-guid')

    q.reset
    q.where(cid: uuid, nummer: 123)
    q.to_s.should == "SELECT * FROM foo WHERE cid = i-am-a-guid AND nummer = 123"

    expect {
      Virsandra::Query.insert.into(:foo).where(id: 1)
    }.to raise_error(Virsandra::InvalidQuery)
  end

  it "can add values to an insert statement" do
    q = Virsandra::Query.insert.into(:foo).values(id: 93, comment: "Stuff!")
    q.to_s.should == "INSERT INTO foo (id, comment) VALUES (93, 'Stuff!')"

    uuid = SimpleUUID::UUID.new
    uuid.stub(to_guid: 'i-am-a-guid')

    q.values(fun: 'time', lol: 'who', uuidz: uuid)
    q.to_s.should == "INSERT INTO foo (fun, lol, uuidz) VALUES ('time', 'who', i-am-a-guid)"

    expect {
      Virsandra::Query.select.from(:foo).values(id: 1)
    }.to raise_error(Virsandra::InvalidQuery)
  end

  it "alters the table" do
    query = Virsandra::Query.alter.table(:foo).add(:name)
    query.to_s.should == "ALTER TABLE foo ADD name varchar"

    query.add(:patents, :integer)
    query.to_s.should == "ALTER TABLE foo ADD patents integer"

    expect {
      Virsandra::Query.select.from(:foo).add(:funky)
    }.to raise_error(Virsandra::InvalidQuery)

  end

  it "executes the query" do
    q = Virsandra::Query.select.from(:foo).where({:id => 123, :name => "Funky"})

    Virsandra.should_receive(:execute).
      with("SELECT * FROM foo WHERE id = 123 AND name = 'Funky'")

    q.execute
  end

  it "can fetch the row with symbolized keys" do
    query = Virsandra::Query.select.from(:foo).where({:id => "0123", :name => "Funky"})

    query.should_receive(:execute)
    query.should_receive(:fetch_with_symbolized_keys)
    query.fetch
  end


  it "can fetch a raw query" do
    cql = "SELECT * FROM cities WHERE town = 'funky'"
    query = Virsandra::Query.new

    Virsandra.should_receive(:execute).with(cql)

    query.fetch(cql)
  end

end
