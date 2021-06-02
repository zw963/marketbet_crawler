class Institution < Sequel::Model
  many_to_one :stock
end
