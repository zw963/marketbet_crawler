Sequel.migration do
  change do
    alter_table(:investing_latest_news) do
      add_column :updated_at, DateTime
    end
  end
end
