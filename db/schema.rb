Sequel.migration do
  change do
    create_table(:institutions) do
      primary_key :id
      String :name, :size=>255, :null=>false
      Integer :number_of_holding, :null=>false
      Integer :market_value
      BigDecimal :percent_of_shares_for_stock
      BigDecimal :percent_of_shares_for_institution
      BigDecimal :quarterly_changes_percent
      Integer :quarterly_changes
      String :stock_name, :size=>255, :null=>false
      String :market_value_dollar_string, :size=>255, :null=>false
      BigDecimal :holding_cost, :null=>false
      Date :date, :null=>false
    end
    
    create_table(:schema_migrations) do
      String :filename, :size=>255, :null=>false
      
      primary_key [:filename]
    end
  end
end
