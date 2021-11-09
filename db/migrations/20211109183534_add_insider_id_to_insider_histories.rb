Sequel.migration do
  change do
    alter_table(:insider_histories) do
      add_foreign_key :insider_id, :insiders
    end
  end
end
