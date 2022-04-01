require 'test_helper'

describe '/stocks' do
  it 'should route to routes/stocks/index and response successful' do
    create(:stock, name: 'nyse/ge', percent_of_institutions: 0.5525, id: 1)
    create(:stock, name: 'nyse/lu', percent_of_institutions: 0.2233, id: 2)
    get '/stocks', {'stock_name' => 'nyse/lu'}
    assert_predicate last_response, :ok?
    get '/stocks', {'page' => 1, 'per' => 1}
    assert_predicate last_response, :ok?
    get '/stocks', {'sort_column' => 'exchange_name', 'sort_direction' => 'desc'}
    assert_predicate last_response, :ok?
  end

  it 'test /stocks.json return json' do
    create(:stock, name: 'nyse/ge', percent_of_institutions: 0.5525, id: 1)
    create(:stock, name: 'nyse/lu', percent_of_institutions: 0.2233, id: 2)

    get '/stocks.json'

    assert_equal last_response.body, {'nyse/ge' => 'nyse/ge', 'nyse/lu' => 'nyse/lu'}.to_json
  end
end
