Sequel.migration do
  change do
    alter_table(:jin10_messages) do
      add_index :jin10_message_tag_id
    end
  end
end
