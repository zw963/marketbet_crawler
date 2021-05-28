Sequel.migration do
  change do
    alter_table(:stocks) do
      add_column :percent_of_institutions, BigDecimal
    end
  end
end
