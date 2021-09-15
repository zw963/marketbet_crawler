require 'test_helper'

describe 'test /stocks' do
  it 'test /stocks return a stock lists' do
    exchange = Exchange.create(name: 'nyse')
    create(:stock, name: 'ge', exchange: exchange, percent_of_institutions: 0.5525, id: 1)
    create(:stock, name: 'lu', exchange: exchange, percent_of_institutions: 0.2233, id: 2)

    get "/stocks"

    last_response.body.must_equal File.read('test/stocks.html')
  end

  it 'test /stocks.json return json' do
    exchange = Exchange.create(name: 'nyse')
    create(:stock, name: 'ge', exchange: exchange, percent_of_institutions: 0.5525, id: 1)
    create(:stock, name: 'lu', exchange: exchange, percent_of_institutions: 0.2233, id: 2)

    get "/stocks.json"

    last_response.body.must_equal({ge: 1, lu: 2}.to_json)
  end
end
