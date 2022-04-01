require 'test_helper'

describe 'routes/insider_histories/index' do
  it 'should retrive last 7 days insider histories' do
    create(:insider_history, stock: create(:stock, name: 'nyse/ge'))
    get '/latest-insider-histories'
    assert_predicate last_response, :ok?
  end

  it 'should retrive last 30 days insider histories' do
    create(:insider_history, stock: create(:stock, name: 'nyse/ge'))
    get '/latest-insider-histories', {'days' => 30}
    assert_predicate last_response, :ok?
  end

  it 'should return insider histories for stock nyse/ge' do
    create(:insider_history, stock: create(:stock, name: 'nyse/ge'))
    get '/latest-insider-histories', {'stock_name' => 'nyse/ge'}
    assert_predicate last_response, :ok?
  end

  it 'should return insider histories for stock nyse/ge' do
    create(:insider_history, stock: create(:stock, name: 'nyse/ge'))
    get '/latest-insider-histories', {'xxx' => 'aaa'}
    assert_predicate last_response, :ok?
  end
end
