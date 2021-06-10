class AR::ApplicationRecord < ActiveRecord::Base
  establish_connection(
    "adapter" => "sqlite3",
    "database"  => "db/marketbet_crawler.db"
  )
  self.abstract_class = true
end
