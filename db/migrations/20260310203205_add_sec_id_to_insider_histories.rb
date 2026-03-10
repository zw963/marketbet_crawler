Sequel.migration do
  change do
    add_column :insider_histories, :sec_id, String
  end
end
