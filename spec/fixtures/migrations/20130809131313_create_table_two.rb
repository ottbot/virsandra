class CreateTableTwo
  def up
    Virsandra::Keyspace.new(TEST_KEYSPACE).create_table("table_two", [
      "id uuid primary key",
      "name text"
    ])
  end
end