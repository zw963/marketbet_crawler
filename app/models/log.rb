class Log < Sequel::Model
end

# Table: logs
# -------------------------------------------------------
# Columns:
#  id          | integer      | PRIMARY KEY AUTOINCREMENT
#  type        | varchar(255) | NOT NULL
#  finished_at | Datetime     |
#  created_at  | timestamp    | NOT NULL
# -------------------------------------------------------
