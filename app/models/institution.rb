class Institution < Sequel::Model
  many_to_one :stock
  many_to_one :firm
end

# Table: institutions
# -----------------------------------------------------------------------------
# Columns:
#  id                                | integer      | PRIMARY KEY AUTOINCREMENT
#  name                              | varchar(255) | NOT NULL
#  number_of_holding                 | integer      | NOT NULL
#  market_value                      | integer      |
#  percent_of_shares_for_stock       | numeric      |
#  percent_of_shares_for_institution | numeric      |
#  quarterly_changes_percent         | numeric      |
#  quarterly_changes                 | integer      |
#  market_value_dollar_string        | varchar(255) |
#  holding_cost                      | numeric      |
#  date                              | Date         |
#  created_at                        | timestamp    |
#  stock_id                          | integer      |
# Foreign key constraints:
#  (stock_id) REFERENCES stocks
# -----------------------------------------------------------------------------
