Sequel.migration do
  change do
    create_table(:exchanges, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :size=>255, :null=>false
      
      index [:name], :name=>:sqlite_autoindex_exchanges_1, :unique=>true
    end
    
    create_table(:firms) do
      primary_key :id
      String :name, :size=>255, :null=>false
      String :display_name, :size=>255
    end
    
    create_table(:logs) do
      primary_key :id
      String :type, :size=>255, :null=>false
      DateTime :finished_at
      DateTime :created_at, :null=>false
    end
    
    create_table(:schema_migrations) do
      String :filename, :size=>255, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:new_stocks) do
      primary_key :id
      String :name, :size=>255, :null=>false
      foreign_key :exchange_id, :exchanges
      BigDecimal :percent_of_institutions
    end
    
    create_table(:stocks, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :size=>255, :null=>false
      foreign_key :exchange_id, :exchanges
      BigDecimal :percent_of_institutions
      
      index [:name], :name=>:sqlite_autoindex_stocks_1, :unique=>true
    end
    
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
      foreign_key :stock_id, :stocks
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
      String :market_value_dollar_string, :size=>255
      BigDecimal :holding_cost
      Date :date
      DateTime :created_at
      foreign_key :stock_id, :stocks
      foreign_key :firm_id, :firms
    end
  end
end
