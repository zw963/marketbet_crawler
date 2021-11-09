Sequel.migration do
  change do
    alter_table(:insider_histories) do
      drop_column :name
    end
  end
end
