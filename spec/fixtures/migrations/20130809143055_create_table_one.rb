class CreateTableOne
  def up
    Virsandra::Keyspace.new(TEST_KEYSPACE).create_table("table_one", [
      "id uuid primary key",
      "name text"
    ])
  end
end