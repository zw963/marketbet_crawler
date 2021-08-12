Sequel.migration do
  change do
    create_table(:firms) do
      primary_key :id
      String :name, null: false
      String :display_name
    end
  end
end
