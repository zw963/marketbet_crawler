Sequel.migration do
  change do
    add_column :institutions, :average_cost, BigDecimal
  end
end
