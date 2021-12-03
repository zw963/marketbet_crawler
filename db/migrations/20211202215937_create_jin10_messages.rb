Sequel.migration do
  change do
    create_table(:jin10_messages) do
      primary_key :id
      String :title
      Date :publish_date
      String :publish_time_string
      String :category
      String :url
      TrueClass :important, index: true, default: false
      DateTime :created_at
      DateTime :updated_at
      index [:title, :publish_date], unique: true
    end
  end
end
