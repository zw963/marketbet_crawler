Sequel.migration do
  change do
    create_table(:investing_latest_news) do
      primary_key :id
      String :url, null: false
      String :title, null: false
      String :preview, null: false
      String :source, null: false
      String :publish_time_string, null: false
      DateTime :publish_time, null: false
      DateTime :created_at, null: false
      index :url
      index :publish_time
    end
  end
end
