require 'feature_helper'

describe "Keyspace", integration: true do
  let(:keyspace_name){ "virsandra_test_keyspace_two" }
  let(:options){ {} }
  subject(:keyspace){ Virsandra::Keyspace.new(keyspace_name) }

  describe "creating keyspace" do
    let(:options){ {replication: {class: 'SimpleStrategy', replication_factor: 1}, durable_writes: false } }

    after do
      old_keyspace = Virsandra.keyspace.clone
      Virsandra.keyspace = "system"
      Virsandra.execute("DROP KEYSPACE #{keyspace_name}")
      Virsandra.keyspace = old_keyspace
    end

    it 'create keyspace with replication and durable writes' do
      keyspace.exists?.should be_false
      keyspace.create(options)
      keyspace.exists?.should be_true
    end
  end

  describe "dropping keyspace" do
    it 'drops keyspace' do
      pending
    end
  end
end