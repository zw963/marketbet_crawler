class Firm < Sequel::Model
  one_to_many :institutions
end

# Table: firms
# --------------------------------------------------------
# Columns:
#  id           | integer      | PRIMARY KEY AUTOINCREMENT
#  name         | varchar(255) | NOT NULL
#  display_name | varchar(255) |
# --------------------------------------------------------
