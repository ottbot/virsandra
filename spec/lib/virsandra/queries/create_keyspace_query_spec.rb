require 'spec_helper'

describe Virsandra::CreateKeyspaceQuery do
  let(:keyspace_name){ "my_keyspace" }
  subject(:query){ described_class.new(keyspace_name) }

  describe "#to_s" do
    it "should raise an error when no replication strategy given" do
      expect{ query.to_s }.to raise_error(Virsandra::InvalidQuery, "Replication strategy is mandatory")
    end
  end

  describe '#with' do
    subject{ super().with(replication: {class: "SimpleStrategy"} ).to_s }

    it {should eq("CREATE KEYSPACE my_keyspace WITH replication = { 'class': 'SimpleStrategy' }")}
  end

  describe '#and' do
    subject{ super().with(replication: {class: "SimpleStrategy"}).and(durable_writes: false).to_s }

    it { should eq("CREATE KEYSPACE my_keyspace WITH replication = { 'class': 'SimpleStrategy' } AND durable_writes = false") }
  end
end