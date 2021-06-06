Sequel.migration do
  change do
    create_table(:new_stocks, as: DB[:stocks])
  end
end
