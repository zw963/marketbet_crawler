Sequel.migration do
  change do
    create_table(:institutions) do
      primary_key :id
      String :name, null: false
      Integer :number_of_holding, null: false
      BigDecimal :market_value
      BigDecimal :percent_of_shares_for_stock
      BigDecimal :percent_of_shares_for_institution
      BigDecimal :quarterly_changes_percent
      Integer :quarterly_changes
    end
  end
end
