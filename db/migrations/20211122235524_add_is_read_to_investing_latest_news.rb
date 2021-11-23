Sequel.migration do
  change do
    alter_table(:investing_latest_news) do
      add_column :is_read, TrueClass, default: false
    end
  end
end
