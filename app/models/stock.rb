class Stock < Sequel::Model
  many_to_one :exchange
end
