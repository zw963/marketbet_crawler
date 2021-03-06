class Insider < Sequel::Model
  one_to_many :insider_histories
end

# Table: insiders
# ---------------------------------------------------------------------------------------------
# Columns:
#  id                    | integer | PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
#  name                  | text    |
#  last_trade_date       | date    |
#  number_of_trade_times | integer |
#  last_trade_stock      | text    |
#  trade_on_stock_amount | integer |
# Indexes:
#  insiders_pkey1 | PRIMARY KEY btree (id)
# Referenced By:
#  insider_histories | insider_histories_insider_id_fkey | (insider_id) REFERENCES insiders(id)
# ---------------------------------------------------------------------------------------------
