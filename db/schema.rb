Sequel.migration do
  change do
    create_table(:exchanges) do
      primary_key :id
      column :name, "text", :null=>false
      
      index [:name], :name=>:exchanges_name_key, :unique=>true
    end
    
    create_table(:insiders) do
      primary_key :id
      column :name, "text"
      column :last_trade_date, "date"
      column :number_of_trade_times, "integer"
      column :last_trade_stock, "text"
      column :trade_on_stock_amount, "integer"
    end
    
    create_table(:institutions) do
      primary_key :id
      column :name, "text", :null=>false
      column :display_name, "text"
    end
    
    create_table(:investing_latest_news) do
      primary_key :id
      column :url, "text", :null=>false
      column :title, "text", :null=>false
      column :preview, "text", :null=>false
      column :source, "text", :null=>false
      column :publish_time_string, "text", :null=>false
      column :publish_time, "timestamp without time zone", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone"
      column :textsearchable_index_col, "tsvector", :generated_always_as=>Sequel::LiteralString.new("to_tsvector('zhparser'::regconfig, ((COALESCE(title, ''::text) || ' '::text) || COALESCE(preview, ''::text)))")
      column :is_read, "boolean", :default=>false
      
      index [:publish_time]
      index [:textsearchable_index_col], :name=>:investing_latest_news_textsearch_idx_index
      index [:url]
    end
    
    create_table(:jin10_message_categories) do
      primary_key :id
      column :name, "text"
      
      index [:name], :name=>:jin10_message_categories_name_key, :unique=>true
    end
    
    create_table(:jin10_message_tags) do
      primary_key :id
      column :name, "text"
      
      index [:name], :name=>:jin10_message_tags_name_key, :unique=>true
    end
    
    create_table(:logs) do
      primary_key :id
      column :type, "text", :null=>false
      column :finished_at, "timestamp without time zone"
      column :created_at, "timestamp without time zone", :null=>false
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:jin10_messages) do
      primary_key :id
      column :title, "text"
      column :publish_date, "date"
      column :publish_time_string, "text"
      column :important, "boolean", :default=>false
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      column :keyword, "text", :default=>"", :null=>false
      column :jin10_message_tag_id, "integer"
      foreign_key :jin10_message_category_id, :jin10_message_categories, :key=>[:id]
      column :textsearchable_index_col, "tsvector", :generated_always_as=>Sequel::LiteralString.new("to_tsvector('zhparser'::regconfig, title)")
      column :properties, "jsonb", :default=>Sequel::LiteralString.new("'{}'::jsonb")
      
      index [:important]
      index [:jin10_message_tag_id]
      index [:textsearchable_index_col], :name=>:jin10_messages_textsearch_idx_index
      index [:title, :publish_date], :unique=>true
    end
    
    create_table(:new_stocks) do
      primary_key :id
      column :name, "text", :null=>false
      foreign_key :exchange_id, :exchanges, :key=>[:id]
      column :percent_of_institutions, "numeric"
    end
    
    create_table(:stocks) do
      primary_key :id
      column :name, "text", :null=>false
      foreign_key :exchange_id, :exchanges, :key=>[:id]
      column :percent_of_institutions, "numeric"
      column :ipo_price, "text"
      column :ipo_amount, "numeric"
      column :ipo_placement, "text"
      column :ipo_date, "date"
      column :ipo_average_price, "numeric"
      column :ipo_placement_number, "numeric"
      column :next_earnings_date, "date"
      
      index [:name], :name=>:stocks_name_key, :unique=>true
    end
    
    create_table(:insider_histories) do
      primary_key :id
      column :date, "date", :null=>false
      column :title, "text", :null=>false
      column :number_of_holding, "integer"
      column :number_of_shares, "integer", :null=>false
      column :average_price, "numeric", :null=>false
      column :share_total_price, "numeric", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      foreign_key :stock_id, :stocks, :key=>[:id]
      foreign_key :insider_id, :insiders, :key=>[:id]
    end
    
    create_table(:institution_histories) do
      primary_key :id
      column :number_of_holding, "integer", :null=>false
      column :market_value, "numeric"
      column :percent_of_shares_for_stock, "numeric"
      column :percent_of_shares_for_institution, "numeric"
      column :quarterly_changes_percent, "numeric"
      column :quarterly_changes, "integer"
      column :market_value_dollar_string, "text"
      column :holding_cost, "numeric"
      column :date, "date"
      column :created_at, "timestamp without time zone"
      foreign_key :stock_id, :stocks, :key=>[:id]
      foreign_key :institution_id, :institutions, :key=>[:id]
    end
  end
end
