Sequel.migration do
  change do
    add_column :institutions, :stock_name, String, null: false
  end
end
