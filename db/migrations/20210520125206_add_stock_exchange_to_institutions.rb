Sequel.migration do
  change do
    add_column :institutions, :stock_exchange, String
  end
end
