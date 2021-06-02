Sequel.migration do
  change do
    alter_table(:insiders) do
      add_foreign_key :stock_id, :stocks
    end
  end
end
