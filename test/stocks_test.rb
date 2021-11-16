require 'test_helper'

describe 'test /stocks' do
  it 'test /stocks return a stock lists' do
    exchange = Exchange.create(name: 'nyse')
    create(:stock, name: 'nyse/ge', exchange: exchange, percent_of_institutions: 0.5525, id: 1)
    create(:stock, name: 'nyse/lu', exchange: exchange, percent_of_institutions: 0.2233, id: 2)

    get "/stocks"

    last_response.body.must_equal File.read('test/stocks.html')
    # pp_to_file 'test/stocks.html', last_response.body
  end

  it 'test /stocks.json return json' do
    exchange = Exchange.create(name: 'nyse')
    create(:stock, name: 'nyse/ge', exchange: exchange, percent_of_institutions: 0.5525, id: 1)
    create(:stock, name: 'nyse/lu', exchange: exchange, percent_of_institutions: 0.2233, id: 2)

    get "/stocks.json"

    last_response.body.must_equal({'nyse/ge' => 'nyse/ge', 'nyse/lu' => 'nyse/lu'}.to_json)
  end
end
