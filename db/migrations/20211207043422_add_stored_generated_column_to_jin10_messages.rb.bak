Sequel.migration do
  up do
    if DB.adapter_scheme == :postgres
      run <<~'HEREDOC'
        ALTER TABLE jin10_messages
        ADD COLUMN textsearchable_index_col tsvector GENERATED ALWAYS
            AS
            (
                to_tsvector(
                  'zhparser', title
                )
            )
        STORED;
      HEREDOC
      run 'CREATE INDEX jin10_messages_textsearch_idx_index ON jin10_messages USING GIN (textsearchable_index_col);'
    end
  end

  down do
    if DB.adapter_scheme == :postgres
      alter_table(:jin10_messages) do
        drop_index :textsearch_idx, if_exists: true
        drop_column :textsearchable_index_col, if_exists: true
      end
    end
  end
end

# usage
# DB.fetch('SELECT * FROM jin10_messages WHERE textsearchable_index_col @@ to_tsquery(?)', "kw1 | kw2").all
