Sequel.migration do
  change do
    alter_table(:jin10_messages) do
      drop_column :tag
    end
  end
end
