require 'test_helper'

describe 'routes/insider_histories/index' do
  it 'should retrive insider histories' do
    create(:insider_history, stock: create(:stock, name: 'nyse/ge'))
    get '/latest-insider-histories'
    assert last_response.ok?
    get '/latest-insider-histories?stock_name=nyse/lu'
    assert last_response.ok?
  end
end
