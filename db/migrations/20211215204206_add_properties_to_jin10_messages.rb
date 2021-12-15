DB.extension :pg_json

Sequel.migration do
  change do
    alter_table(:jin10_messages) do
      add_column :properties, :jsonb, default: '{}'
    end
  end
end
