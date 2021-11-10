Sequel.migration do
  change do
    alter_table(:insiders) do
      add_column :last_trade_date, Date
    end
  end
end
