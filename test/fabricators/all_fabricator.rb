require 'bigdecimal'
require 'bigdecimal/util'

Fabricate.sequence(:name) { |i| "Name #{i}" }
Fabricate.sequence(:date) {|_n| Date.today + rand(-100..100) }

Fabricator(:institution) do
  name { Fabricate.sequence(:name) }
  number_of_holding 69830
  market_value 940000
  stock
  percent_of_shares_for_stock 0.024.to_d
  percent_of_shares_for_institution 0.02.to_d
  market_value_dollar_string "$0.94M"
end

Fabricator(:firm) do
  name { Fabricate.sequence(:name) }
end

Fabricator(:stock) do
  name { Fabricate.sequence(:name) }
  exchange
end

Fabricator(:exchange) do
  name { %w(otcmkts nyse nasdaq nyseamerican lon).sample }
end

Fabricator(:insider) do
  date { Fabricate.sequence(:date) }
  name { Fabricate.sequence(:name) }
  title 'Major Shareholder'
  number_of_shares (-220809)
  average_price 1.92.to_d
  share_total_price 423953.28.to_d
  stock
end
