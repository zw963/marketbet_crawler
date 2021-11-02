Sequel.migration do
  change do
    alter_table(:stocks) do
      add_column :next_earnings_date, Date
    end
  end
end
