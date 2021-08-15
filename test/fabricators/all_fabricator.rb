require 'bigdecimal'
require 'bigdecimal/util'

Fabricate.sequence(:name) { |i| "Name #{i}" }
Fabricate.sequence(:date) {|_n| Date.today + rand(-100..100) }

Fabricator(:institution) do
  name { sequence(:name) }
  number_of_holding 50
  market_value 100
  stock
  percent_of_shares_for_stock 0.24.to_d
  percent_of_shares_for_institution 0.02.to_d
end

Fabricator(:firm) do
  name { sequence(:name) }
end

Fabricator(:stock) do
  name { sequence(:name) }
  exchange
end

Fabricator(:exchange) do
  name { sequence(:name) }
end

Fabricator(:insider) do
  date { sequence(:date) {|_n| Date.today + rand(-100..100) } }
  name { sequence(:name) }
  date { sequence(:date) }
  title 'ceo'
  number_of_shares 100
  average_price 1.24.to_d
  share_total_price 300.2.to_d
  stock
end
