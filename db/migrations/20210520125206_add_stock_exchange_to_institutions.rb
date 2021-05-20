Sequel.migration do
  change do
    add_column :institutions, :stock_exchange, String, null: false
  end
end
