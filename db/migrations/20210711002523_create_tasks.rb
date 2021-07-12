Sequel.migration do
  change do
    create_table(:tasks) do
      primary_key :id
      String :title
      Boolean :is_done
      DateTime :due
    end
  end
end
