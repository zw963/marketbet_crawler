Sequel.migration do
  change do
    rename_table :institutions, :institution_histories
  end
end
