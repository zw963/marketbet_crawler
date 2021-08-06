Sequel.migration do
  change do
    create_table(:logs) do
      primary_key :id
      String :type, null: false
      Datetime :finished_at
      DateTime :created_at, null: false
    end
  end
end
