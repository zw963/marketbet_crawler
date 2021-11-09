class InsiderHistory < Sequel::Model
  many_to_one :stock
end

# Table: insiders
# -------------------------------------------------------------
# Columns:
#  id                | integer      | PRIMARY KEY AUTOINCREMENT
#  date              | date         | NOT NULL
#  name              | varchar(255) | NOT NULL
#  title             | varchar(255) | NOT NULL
#  number_of_holding | integer      |
#  number_of_shares  | integer      | NOT NULL
#  average_price     | numeric      | NOT NULL
#  share_total_price | numeric      | NOT NULL
#  created_at        | timestamp    | NOT NULL
#  stock_id          | integer      |
# Foreign key constraints:
#  (stock_id) REFERENCES stocks
# -------------------------------------------------------------
