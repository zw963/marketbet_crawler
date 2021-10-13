Sequel.migration do
  change do
    alter_table(:stocks) do
      add_column :ipo_price, String
      add_column :ipo_amount, BigDecimal
      add_column :ipo_placement, String
      add_column :ipo_date, Date
    end
  end
end
