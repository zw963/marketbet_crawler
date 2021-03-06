class Jin10Message < Sequel::Model
  many_to_one :category, key: :jin10_message_category_id, class: 'Jin10MessageCategory'
  many_to_one :tag, key: :jin10_message_tag_id, class: 'Jin10MessageTag'

  self.skip_saving_columns = [:textsearchable_index_col]

  store_accessor :properties, :url, :image_url

  def display_time
    if self[:publish_date] == Date.today
      self[:publish_time_string]
    else
      self[:publish_date]
    end
  end
end

# Table: jin10_messages
# --------------------------------------------------------------------------------------------------------------------
# Columns:
#  id                        | integer                     | PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
#  title                     | text                        |
#  publish_date              | date                        |
#  publish_time_string       | text                        |
#  important                 | boolean                     | DEFAULT false
#  created_at                | timestamp without time zone |
#  updated_at                | timestamp without time zone |
#  keyword                   | text                        | NOT NULL DEFAULT ''::text
#  jin10_message_tag_id      | integer                     |
#  jin10_message_category_id | integer                     |
#  textsearchable_index_col  | tsvector                    | DEFAULT to_tsvector('zhparser'::regconfig, title)
#  properties                | jsonb                       | DEFAULT '{}'::jsonb
# Indexes:
#  jin10_messages_pkey                       | PRIMARY KEY btree (id)
#  jin10_messages_title_publish_date_index   | UNIQUE btree (title, publish_date)
#  jin10_messages_important_index            | btree (important)
#  jin10_messages_jin10_message_tag_id_index | btree (jin10_message_tag_id)
#  jin10_messages_textsearch_idx_index       | gin (textsearchable_index_col)
# Foreign key constraints:
#  jin10_messages_jin10_message_category_id_fkey | (jin10_message_category_id) REFERENCES jin10_message_categories(id)
# --------------------------------------------------------------------------------------------------------------------
