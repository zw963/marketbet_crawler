Sequel.migration do
  change do
    add_column :insider_histories, :transaction_code, String
  end
end
