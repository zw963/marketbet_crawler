Sequel.migration do
  change do
    alter_table(:institutions) do
      add_foreign_key :stock_id, :stocks
    end
  end
end
