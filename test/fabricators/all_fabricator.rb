Fabricate.sequence(:name) { |i| "Name #{i}" }
Fabricate.sequence(:title) { |i| "Title #{i}" }
Fabricate.sequence(:date) {|n| Date.today + rand(-100..100) }

Fabricator(:institution) do
  name { sequence(:name) { |i| "institution #{i}" } }
  number_of_holding 50
  market_value 100
  stock
  percent_of_shares_for_stock { BigDecimal('0.24') }
  percent_of_shares_for_institution { BigDecimal('0.02') }
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
  avarage_price BigDecimal(1.24)
  share_total_price BigDecimal(300.2)
  stock
end
