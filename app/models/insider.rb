class Insider < Sequel::Model
  many_to_one :stock
end
