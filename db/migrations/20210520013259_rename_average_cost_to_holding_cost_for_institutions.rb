Sequel.migration do
  change do
    rename_column :institutions, :average_cost, :holding_cost
  end
end
