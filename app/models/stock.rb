class Stock < Sequel::Model
  many_to_one :exchange
  one_to_many :institutions
end

# Table: stocks
# -------------------------------------------------------------------
# Columns:
#  id                      | integer      | PRIMARY KEY AUTOINCREMENT
#  name                    | varchar(255) | NOT NULL
#  exchange_id             | integer      |
#  percent_of_institutions | numeric      |
# Indexes:
#  sqlite_autoindex_stocks_1 | UNIQUE (name)
# Foreign key constraints:
#  (exchange_id) REFERENCES exchanges
# -------------------------------------------------------------------
