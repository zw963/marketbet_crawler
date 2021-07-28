class Exchange < Sequel::Model
end

# Table: exchanges
# ------------------------------------------------
# Columns:
#  id   | integer      | PRIMARY KEY AUTOINCREMENT
#  name | varchar(255) | NOT NULL
# Indexes:
#  sqlite_autoindex_exchanges_1 | UNIQUE (name)
# ------------------------------------------------
