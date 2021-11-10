Sequel.migration do
  change do
    alter_table(:insiders) do
      add_column :number_of_trade_times, Integer
    end
  end
end
