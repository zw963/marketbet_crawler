Sequel.migration do
  change do
    create_table(:insiders) do
      primary_key :id
      Date :date, :null=>false
      String :name, :size=>255, :null=>false
      String :title, :size=>255, :null=>false
      Integer :number_of_holding
      Integer :number_of_shares, :null=>false
      BigDecimal :average_price, :null=>false
      BigDecimal :share_total_price, :null=>false
      DateTime :created_at, :null=>false
    end
    
    create_table(:institutions) do
      primary_key :id
      String :name, :size=>255, :null=>false
      Integer :number_of_holding, :null=>false
      Integer :market_value
      BigDecimal :percent_of_shares_for_stock
      BigDecimal :percent_of_shares_for_institution
      BigDecimal :quarterly_changes_percent
      Integer :quarterly_changes
      String :stock_name, :size=>255
      String :market_value_dollar_string, :size=>255
      BigDecimal :holding_cost
      Date :date
      String :stock_exchange, :size=>255
      DateTime :created_at
    end
    
    create_table(:schema_migrations) do
      String :filename, :size=>255, :null=>false
      
      primary_key [:filename]
    end
  end
end
