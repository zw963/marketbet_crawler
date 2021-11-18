require 'test_helper'

describe '/latest-institutions' do
  it 'should response succssful.' do
    3.times { create(:institution) }
    get "/latest-institutions"
    assert last_response.ok?
  end

  it 'should search by stock_name successful' do
    create(:institution, stock: create(:stock, name: 'nyse/ge'))
    get "/latest-institutions", {'stock_name' => 'nyse/ge'}
    assert last_response.ok?
  end

  it 'should search by days sucessful' do
    create(:institution)
    get "/latest-institutions", {'days' => 1}
    assert last_response.ok?
  end
end
