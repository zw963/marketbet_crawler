Sequel.migration do
  change do
    alter_table(:institution_histories) do
      rename_column :firm_id, :institution_id
    end
  end
end
