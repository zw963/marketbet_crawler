Sequel.migration do
  change do
    alter_table(:stocks) do
      add_column :ipo_average_price, BigDecimal
      add_column :ipo_placement_number, BigDecimal
    end
  end
end
