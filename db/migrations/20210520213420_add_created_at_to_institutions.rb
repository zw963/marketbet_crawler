Sequel.migration do
  change do
    add_column :institutions, :created_at, DateTime
  end
end
