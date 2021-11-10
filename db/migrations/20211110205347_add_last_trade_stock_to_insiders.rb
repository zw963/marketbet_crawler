Sequel.migration do
  change do
    alter_table(:insiders) do
      add_column :last_trade_stock, String
    end
  end
end
