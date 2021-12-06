Sequel.migration do
  change do
    create_table(:jin10_message_tags) do
      primary_key :id
      String :name, unique: true
    end
  end
end
