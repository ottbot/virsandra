require 'spec_helper'

class Company
  include Virsandra::Model

  attribute :id, SimpleUUID::UUID, :default => proc { SimpleUUID::UUID.new }
  attribute :name, String
  attribute :score, Fixnum
  attribute :founded, Fixnum
  attribute :founder, String

  table :companies
  key :id, :score
end


describe Virsandra::Model do

  let(:id) { SimpleUUID::UUID.new }

  let(:company) { Company.new(id: id, name: "Testco", score: 78)}

  it "has attributes" do
    company.attributes.should be_a Hash
  end

  it "selects keys" do
    company.key.should == {id: id, score: 78}
  end

  it "reads the configured table" do
    company.table.should == :companies
  end

  it "is valid with a key" do
    company.should be_valid
  end

  it "is invalid when a key element is nil" do
    company.id = nil
    company.should_not be_valid
  end

  describe "with no assigned id" do
    it "creates unique uuid's for each instance" do
      company_one = Company.new(name: 'x')
      company_two = Company.new(name: 'x')
      company_one.should_not == company_two
      company_one[:id].should_not == company_two[:id]
    end
  end

  it "is equivelent with the same model same attributes" do
    Company.new(id: id, name: 'x').should == Company.new(id: id, name: 'x')
  end

  it "is not equivelent with different attributes" do
    Company.new(id: id, name: 'x').should_not == Company.new(id: id, name: 'y')
  end

  it "is not equivelent to a different model" do
    Company.new(id: id, name: 'x').should_not == stub(attributes: {id: id, name: 'x'})
  end

  describe "finding an existing record" do
    before do
      Virsandra.execute("INSERT INTO companies (id, score, name, founded) VALUES (#{id.to_guid}, 101, 'Funky', 1990)")
    end

    it "can find a record from a key" do
      company = Company.find(id: id, score: 101)
      company.attributes.should == {id: id, score: 101, name: "Funky", founded: 1990, founder: nil}
    end

    it "raises an error with an incomplete key" do
      expect { Company.find(score: 11) }.to raise_error(ArgumentError)
    end

    it "raises an error with an over-specified key" do
      expect { Company.find(score: 11, id: id, name: 'Whatever') }.to raise_error(ArgumentError)
    end

    it "populates missing columns, keeping specified values" do
      attrs = {id: id, name: "Google", score: 101, founder: "Larry Brin"}

      company = Company.load(attrs)
      company.attributes.should == attrs.merge(founded: 1990)
    end
  end

  describe "saving a model" do
    before do
      Virsandra.execute("USE virtest")
      Virsandra.execute("TRUNCATE companies")
    end

    it "can be saved" do
      company = Company.new(id: id, score: 101, name: "Job Place")
      company.save
      Company.find(company.key).should == company
    end

    it "doesn't save when invalid" do
      company = Company.new(name: "Keyless Inc.")
      Virsandra::ModelQuery.should_not_receive(:new)
      company.save
    end
  end

  describe "deleting a model" do
    before do
      Virsandra.execute("USE virtest")
      Virsandra.execute("TRUNCATE companies")
    end

    it "can be deleted" do
      Virsandra.execute("INSERT INTO companies (id, score) VALUES (#{id.to_guid}, 101)")
      company = Company.find(id: id, score: 101)
      company.delete
      Company.where(id: id, score: 101).to_a.should be_empty
    end

    it "only deletes the current model" do
      Virsandra.execute("INSERT INTO companies (id, score) VALUES (#{id.to_guid}, 101)")
      Virsandra.execute("INSERT INTO companies (id, score) VALUES (#{id.to_guid}, 102)")
      company = Company.find(id: id, score: 101)
      company.delete
      Company.where(id: id, score: 102).to_a.should_not be_empty

    end



  end

  describe "working with existing records" do
    before do
      Virsandra.execute("USE virtest")
      Virsandra.execute("TRUNCATE companies")

      5.times { |n| Company.new(id: id, score: n + 1, name: "Test").save }
      5.times { |n| Company.new(id: SimpleUUID::UUID.new, score: n + 1, name: "Test").save }
    end

    it "checks all search terms are attributes" do
      expect { Company.where(id: 1, missing: 'key') }.to raise_error(ArgumentError)
      expect { Company.where(id: id, score: 10) }.not_to raise_error(ArgumentError)
    end

    it "returns an enumerable" do
      Company.where(id: id).should be_an Enumerator
    end

    it "creates an model instance for each entry " do
      Company.where(id: id).map(&:score).should == [1,2,3,4,5]
    end

    it "can get all records" do
      Company.all.to_a.length.should == 10
    end

    it "lazily instanciates models" do
      Company.should_receive(:new).twice
      Company.all.take(2)
    end

    it "can be empty" do
      Company.where(id: id, score: 1009).to_a.should be_empty
    end

  end

end
