Sequel.migration do
  change do
    alter_table(:investing_latest_news) do
      drop_index :textsearch_idx, if_exists: true
      drop_column :textsearchable_index_col, if_exists: true
    end

    alter_table(:jin10_messages) do
      drop_index :textsearch_idx, if_exists: true
      drop_column :textsearchable_index_col, if_exists: true
    end

    if DB.adapter_scheme == :postgres
      run 'ALTER ROLE all RESET ALL'
      run 'DROP TEXT SEARCH CONFIGURATION IF EXISTS zhparser;'
      run 'DROP EXTENSION IF EXISTS zhparser RESTRICT;'
    end
  end
end
