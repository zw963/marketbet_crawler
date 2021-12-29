Sequel.migration do
  change do
    if DB.adapter_scheme == :postgres
      DB.extension :pg_json

      alter_table(:jin10_messages) do
        add_column :properties, :jsonb, default: '{}'
      end
    end
  end
end
