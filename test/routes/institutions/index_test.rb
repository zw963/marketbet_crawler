require 'test_helper'

describe '/latest-institutions' do
  it 'should route to routes/institutions/index and response succssful.' do
    3.times { create(:institution) }
    get "/latest-institutions"
    assert last_response.ok?
    get "/latest-institutions", {'stock_name' => 'nyse/ge'}
    assert last_response.ok?
  end
end
