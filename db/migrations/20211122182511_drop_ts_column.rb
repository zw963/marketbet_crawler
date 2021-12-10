Sequel.migration do
  change do
    if DB.adapter_scheme == :postgres
      alter_table(:investing_latest_news) do
        drop_index :textsearch_idx, if_exists: true
        drop_column :textsearchable_index_col, if_exists: true
      end
    end
  end
end
