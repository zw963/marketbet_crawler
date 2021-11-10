Sequel.migration do
  change do
    alter_table(:insiders) do
      add_column :trade_on_stock_amount, Integer
    end
  end
end
