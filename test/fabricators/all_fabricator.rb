require 'bigdecimal'
require 'bigdecimal/util'

Fabricate.sequence(:name) { |i| "Name #{i}" }
Fabricate.sequence(:title) { |i| "Title #{i}" }
Fabricate.sequence(:date) {|n| Date.today + rand(-100..100) }

Fabricator(:institution) do
  name { sequence(:name) { |i| "institution #{i}" } }
  number_of_holding 50
  market_value 100
  stock
  percent_of_shares_for_stock 0.24.to_d
  percent_of_shares_for_institution 0.02.to_d
end

Fabricator(:stock) do
  name { sequence(:name) { |i| "stock #{i}" } }
  exchange
end

Fabricator(:exchange) do
  name { sequence(:name) { |i| "exchange #{i}" } }
end

Fabricator(:insider) do
  date
  name
  title
  number_of_share 100
  avarage_price 1.24.to_d
  share_total_price 300.2.to_d
  stock
end
