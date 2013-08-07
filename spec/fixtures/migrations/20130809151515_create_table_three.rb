class CreateTableThree
  def up
    Virsandra::Keyspace.new(TEST_KEYSPACE).create_table("table_three", [
      "id uuid primary key",
      "name text"
    ])
  end
end