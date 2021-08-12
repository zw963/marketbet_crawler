Sequel.migration do
  change do
    alter_table(:institutions) do
      add_foreign_key :firm_id, :firms
    end
  end
end
