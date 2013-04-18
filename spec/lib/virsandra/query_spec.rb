require 'spec_helper'

describe Virsandra::Query do

  it "has class methods to create instances for each method" do
    Virsandra::Query.should_receive(:new).with(:select, "*")
    Virsandra::Query.select

    Virsandra::Query.should_receive(:new).with(:select, "a, b, c, d")
    Virsandra::Query.select(:a, :b, :c, :d)

    Virsandra::Query.should_receive(:new).with(:insert)
    Virsandra::Query.insert

    Virsandra::Query.should_receive(:new).with(:delete)
    Virsandra::Query.delete

    Virsandra::Query.should_receive(:new).with(:alter)
    Virsandra::Query.alter
  end

  it "sets the table and statment type on initialization" do
    Virsandra::Query.any_instance.should_receive(:start_query)

    query = Virsandra::Query.new(:insert)
    query.statement.should == :insert
  end

  it "starting building the given statement type" do
    q = Virsandra::Query.new(:select, '*')
    q.to_s.should == "SELECT * FROM"
  end

  it "raises an error if statement is not supported" do
    expect { Virsandra::Query.new(:junk) }.to raise_error { ArgumentError }
  end

  it "adds a from method" do
    q = Virsandra::Query.select.from(:foo)
    q.to_s.should == "SELECT * FROM foo"

    q = Virsandra::Query.insert.into(:foo)
    q.to_s.should == "INSERT INTO foo"

    q = Virsandra::Query.delete.from(:foo)
    q.to_s.should == "DELETE FROM foo"

    q = Virsandra::Query.alter.table(:foo)
    q.to_s.should == "ALTER TABLE foo"
  end

  it "can change the table" do
    q = Virsandra::Query.insert.into(:foo)

    q.into(:bar)
    q.to_s.should == "INSERT INTO bar"
  end

  it "adds a where clause when appropirate" do
    q = Virsandra::Query.select.from(:foo).where(id: 'Funky', location: 'town')
    q.to_s.should == "SELECT * FROM foo WHERE id = 'Funky' AND location = 'town'"

    q.where(can: "change options")
    q.to_s.should == "SELECT * FROM foo WHERE can = 'change options'"

    uuid = SimpleUUID::UUID.new
    uuid.stub(to_guid: 'i-am-a-guid')

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
    query = Virsandra::Query.new(cql)

    Virsandra.should_receive(:execute).with(cql)

    query.fetch
  end

end
