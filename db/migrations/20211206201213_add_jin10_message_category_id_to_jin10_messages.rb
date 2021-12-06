Sequel.migration do
  change do
    alter_table(:jin10_messages) do
      add_foreign_key :jin10_message_category_id, :jin10_message_categories
    end
  end
end
