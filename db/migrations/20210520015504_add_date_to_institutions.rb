Sequel.migration do
  change do
    add_column :institutions, :date, :Date
  end
end
