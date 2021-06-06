class NewStock < Sequel::Model
  many_to_one :exchange
end
