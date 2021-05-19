Sequel.migration do
  change do
    add_column :institutions, :market_value_doller_string, String, null: false
  end
end
