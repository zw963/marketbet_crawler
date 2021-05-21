Sequel.migration do
  change do
    create_table(:stocks) do
      primary_key :id
      String :name, null: false, unique: true
      foreign_key :exchange_id, :exchanges
    end
  end
end
