require 'bigdecimal'
require 'bigdecimal/util'

Fabricator(:institution) do
  name { sequence(:name) { |i| "institution #{i}" } }
  number_of_holding 50
  market_value 100
  stock
  percent_of_shares_for_stock 0.24.to_d
  percent_of_shares_for_institution 0.02.to_d
end

Fabricator(:firm) do
  name { sequence(:name) { |i| "firm #{i}" } }
end

Fabricator(:stock) do
  name { sequence(:name) { |i| "stock #{i}" } }
  exchange
end

Fabricator(:exchange) do
  name { sequence(:name) { |i| "exchange #{i}" } }
end

Fabricator(:insider) do
  date { sequence(:date) {|n| Date.today + rand(-100..100) } }
  name { sequence(:name) { |i| "insider name #{i}" } }
  title 'ceo'
  number_of_shares 100
  average_price 1.24.to_d
  share_total_price 300.2.to_d
  stock
end
