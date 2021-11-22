Sequel.migration do
  change do
    create_table(:exchanges, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :text=>true, :null=>false
      
      index [:name], :name=>:exchanges_name_key, :unique=>true
    end
    
    create_table(:firms) do
      primary_key :id
      String :name, :text=>true, :null=>false
      String :display_name, :text=>true
    end
    
    create_table(:insiders) do
      primary_key :id
      String :name, :text=>true
      Date :last_trade_date
      Integer :number_of_trade_times
      String :last_trade_stock, :text=>true
      Integer :trade_on_stock_amount
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
      DateTime :updated_at
      String :textsearchable_index_col
      
      index [:publish_time]
      index [:textsearchable_index_col], :name=>:investing_latest_news_textsearch_idx_index
      index [:url]
    end
    
    create_table(:logs) do
      primary_key :id
      String :type, :text=>true, :null=>false
      DateTime :finished_at
      DateTime :created_at, :null=>false
    end
    
    create_table(:schema_migrations) do
      String :filename, :text=>true, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:new_stocks) do
      primary_key :id
      String :name, :text=>true, :null=>false
      foreign_key :exchange_id, :exchanges, :key=>[:id]
      BigDecimal :percent_of_institutions
    end
    
    create_table(:stocks, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :text=>true, :null=>false
      foreign_key :exchange_id, :exchanges, :key=>[:id]
      BigDecimal :percent_of_institutions
      String :ipo_price, :text=>true
      BigDecimal :ipo_amount
      String :ipo_placement, :text=>true
      Date :ipo_date
      BigDecimal :ipo_average_price
      BigDecimal :ipo_placement_number
      Date :next_earnings_date
      
      index [:name], :name=>:stocks_name_key, :unique=>true
    end
    
    create_table(:insider_histories) do
      primary_key :id
      Date :date, :null=>false
      String :title, :text=>true, :null=>false
      Integer :number_of_holding
      Integer :number_of_shares, :null=>false
      BigDecimal :average_price, :null=>false
      BigDecimal :share_total_price, :null=>false
      DateTime :created_at, :null=>false
      foreign_key :stock_id, :stocks, :key=>[:id]
      foreign_key :insider_id, :insiders, :key=>[:id]
    end
    
    create_table(:institutions) do
      primary_key :id
      Integer :number_of_holding, :null=>false
      BigDecimal :market_value
      BigDecimal :percent_of_shares_for_stock
      BigDecimal :percent_of_shares_for_institution
      BigDecimal :quarterly_changes_percent
      Integer :quarterly_changes
      String :market_value_dollar_string, :text=>true
      BigDecimal :holding_cost
      Date :date
      DateTime :created_at
      foreign_key :stock_id, :stocks, :key=>[:id]
      foreign_key :firm_id, :firms, :key=>[:id]
    end
  end
end
