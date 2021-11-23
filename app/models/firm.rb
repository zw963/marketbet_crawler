class Firm < Sequel::Model
  one_to_many :institutions
end

# Table: firms
# --------------------------------------------------------------------------
# Columns:
#  id           | integer | PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
#  name         | text    | NOT NULL
#  display_name | text    |
# Indexes:
#  firms_pkey | PRIMARY KEY btree (id)
# Referenced By:
#  institutions | institutions_firm_id_fkey | (firm_id) REFERENCES firms(id)
# --------------------------------------------------------------------------
