Sequel.migration do
  change do
    rename_table :insiders, :insider_histories
  end
end
