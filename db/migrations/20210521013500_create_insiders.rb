Sequel.migration do
  change do
    create_table(:insiders) do
      primary_key :id
      Date :date, null: false
      String :name, null: false
      String :title, null: false
      Integer :number_of_holding
      Integer :number_of_shares, null: false
      BigDecimal :average_price, null: false
      BigDecimal :share_total_price, null: false
      DateTime :created_at, null: false
    end
  end
end
