Sequel.migration do
  change do
    add_column :insiders, :stock_id, Stringb
  end
end
