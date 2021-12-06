Sequel.migration do
  change do
    alter_table(:jin10_messages) do
      add_column :keyword, String, index: true
    end
  end
end
