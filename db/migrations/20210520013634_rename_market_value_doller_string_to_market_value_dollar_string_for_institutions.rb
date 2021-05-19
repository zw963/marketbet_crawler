Sequel.migration do
  change do
    rename_column :institutions, :market_value_doller_string, :market_value_dollar_string
  end
end
