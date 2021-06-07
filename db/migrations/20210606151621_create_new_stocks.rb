Sequel.migration do
  change do
    create_table(:new_stocks) do
      primary_key :id
      String :name, null: false
      foreign_key :exchange_id, :exchanges
      BigDecimal :percent_of_institutions
    end
    from(:new_stocks).insert(from(:stocks))
  end
end
