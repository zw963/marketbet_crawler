Sequel.migration do
  change do
    rename_table :firms, :institutions
  end
end
