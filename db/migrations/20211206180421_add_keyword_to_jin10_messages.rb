Sequel.migration do
  change do
    alter_table(:jin10_messages) do
      add_column :keyword, String, null: false, default: ''
    end
  end
end
