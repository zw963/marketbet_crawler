require 'bigdecimal'
require 'bigdecimal/util'

Fabricate.sequence(:name) { |i| "Name #{i}" }
Fabricate.sequence(:date) {|_n| Date.today + rand(-100..100) }

Fabricator(:institution) do
  holding_cost 7.27
  market_value 940000
  market_value_dollar_string "$0.94M"
  number_of_holding 182902
  percent_of_shares_for_institution 0.02.to_d
  percent_of_shares_for_stock 0.024.to_d
  quarterly_changes 171276
  quarterly_changes_percent 14.732
  firm
  stock
end

Fabricator(:firm) do
  name { Fabricate.sequence(:name) }
end

Fabricator(:stock) do
  name { Fabricate.sequence(:name) }
  exchange { Exchange.find_or_create(name: 'nyse') }
end

Fabricator(:exchange) do
  name 'nyse'
end

Fabricator(:insider_history) do
  date { Fabricate.sequence(:date) }
  title 'Major Shareholder'
  number_of_shares (-220809)
  average_price 1.92.to_d
  share_total_price 423953.28.to_d
  stock
  insider
end

Fabricator(:insider) do
  name { Fabricate.sequence(:name) }
end

Fabricator(:investing_latest_news) do
  url { 'http://example.com' }
  title { '美股异动 | PayPal(PYPL.US)盘前跌逾4%，Q4及全年营收指引低于预期' }
  preview { '智通财经APP获悉，11月9日(周二)美股盘前，截至北京时间17:06，PayPal(PYPL.US)跌4.11%，报220美元。消息面上，PayPal今日公布了截至2021年9月..."' }
  source { '智通财经' }
  publish_time_string { '34 分钟以前' }
  publish_time { Time.parse('2021-11-09 17:36:07') }
end
