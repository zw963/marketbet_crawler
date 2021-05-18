Sequel.migration do
  up do
    create_table(:institutionals) do
      primary_key :id
      String :name, null: false
      Integer :
    end
  end

  down do
    drop_table(:artists)
  end
end
