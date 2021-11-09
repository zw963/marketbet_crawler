Sequel.migration do
  change do
    create_table(:exchanges, :ignore_index_errors=>true) do
      primary_key :id, :type=>:Bignum
      String :name, :size=>255, :null=>false
      
      index [:name], :name=>:sqlite_autoindex_exchanges_1, :unique=>true
    end
    
    create_table(:firms) do
      primary_key :id, :type=>:Bignum
      String :name, :size=>255, :null=>false
      String :display_name, :size=>255
    end
    
    create_table(:insiders) do
      primary_key :id
      String :name, :text=>true
    end
    
    create_table(:investing_latest_news, :ignore_index_errors=>true) do
      primary_key :id
      String :url, :text=>true, :null=>false
      String :title, :text=>true, :null=>false
      String :preview, :text=>true, :null=>false
      String :source, :text=>true, :null=>false
      String :publish_time_string, :text=>true, :null=>false
      DateTime :publish_time, :null=>false
      DateTime :created_at, :null=>false
      
      index [:publish_time]
      index [:url]
    end
    
    create_table(:logs) do
      primary_key :id, :type=>:Bignum
      String :type, :size=>255, :null=>false
      DateTime :finished_at
      DateTime :created_at, :null=>false
    end
    
    create_table(:schema_migrations) do
      String :filename, :size=>255, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:new_stocks) do
      primary_key :id, :type=>:Bignum
      String :name, :size=>255, :null=>false
      foreign_key :exchange_id, :exchanges, :type=>:Bignum, :key=>[:id]
      BigDecimal :percent_of_institutions
    end
    
    create_table(:stocks, :ignore_index_errors=>true) do
      primary_key :id, :type=>:Bignum
      String :name, :size=>255, :null=>false
      foreign_key :exchange_id, :exchanges, :type=>:Bignum, :key=>[:id]
      BigDecimal :percent_of_institutions
      String :ipo_price, :size=>255
      BigDecimal :ipo_amount
      String :ipo_placement, :size=>255
      Date :ipo_date
      BigDecimal :ipo_average_price
      BigDecimal :ipo_placement_number
      Date :next_earnings_date
      
      index [:name], :name=>:sqlite_autoindex_stocks_1, :unique=>true
    end
    
    create_table(:insider_histories) do
      primary_key :id, :type=>:Bignum
      Date :date, :null=>false
      String :name, :size=>255, :null=>false
      String :title, :size=>255, :null=>false
      Bignum :number_of_holding
      Bignum :number_of_shares, :null=>false
      BigDecimal :average_price, :null=>false
      BigDecimal :share_total_price, :null=>false
      DateTime :created_at, :null=>false
      foreign_key :stock_id, :stocks, :type=>:Bignum, :key=>[:id]
      foreign_key :insider_id, :insiders, :key=>[:id]
    end
    
    create_table(:institutions) do
      primary_key :id, :type=>:Bignum
      String :name, :size=>255, :null=>false
      Bignum :number_of_holding, :null=>false
      Bignum :market_value
      BigDecimal :percent_of_shares_for_stock
      BigDecimal :percent_of_shares_for_institution
      BigDecimal :quarterly_changes_percent
      Bignum :quarterly_changes
      String :market_value_dollar_string, :size=>255
      BigDecimal :holding_cost
      Date :date
      DateTime :created_at
      foreign_key :stock_id, :stocks, :type=>:Bignum, :key=>[:id]
      foreign_key :firm_id, :firms, :type=>:Bignum, :key=>[:id]
    end
  end
end
