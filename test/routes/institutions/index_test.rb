require 'test_helper'

describe '/latest-institution-histories' do
  it 'should response succssful.' do
    3.times { create(:institution_history) }
    get "/latest-institution-histories"
    assert last_response.ok?
  end

  it 'should search by stock_name successful' do
    create(:institution_history, stock: create(:stock, name: 'nyse/ge'))
    get "/latest-institution-histories", {'stock_name' => 'nyse/ge'}
    assert last_response.ok?
  end

  it 'should search by days sucessful' do
    create(:institution_history)
    get "/latest-institution-histories", {'days' => 1}
    assert last_response.ok?
  end
end
