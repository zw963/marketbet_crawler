Sequel.migration do
  change do
    alter_table(:institutions) do
      drop_column :stock_name
    end
  end
end
