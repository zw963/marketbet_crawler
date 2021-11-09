Sequel.migration do
  change do
    create_table(:insiders) do
      primary_key :id
      String :name
    end
  end
end
