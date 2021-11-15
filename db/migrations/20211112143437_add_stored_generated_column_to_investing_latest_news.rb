Sequel.migration do
  up do
    run <<'HEREDOC'
ALTER TABLE investing_latest_news
ADD COLUMN textsearchable_index_col tsvector GENERATED ALWAYS
    AS
    (
        to_tsvector(
          'zhparser',
           coalesce(source, '')
             || ' ' ||
           coalesce(title, '')
        )
   )
STORED;
HEREDOC
    run 'CREATE INDEX investing_latest_news_textsearch_idx_index ON investing_latest_news USING GIN (textsearchable_index_col);'
  end

  down do
    alter_table(:investing_latest_news) do
      drop_index :textsearch_idx, if_exists: true
      drop_column :textsearchable_index_col, if_exists: true
    end
  end
end

# usage
# DB.fetch('SELECT * FROM investing_latest_news WHERE textsearchable_index_col @@ to_tsquery(?)', "正加剧市场泡沫").al
