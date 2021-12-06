Sequel.migration do
  change do
    alter_table(:jin10_messages) do
      add_column :jin10_message_tag_id, Integer
    end
  end
end
