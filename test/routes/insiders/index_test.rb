require 'test_helper'

describe 'routes/insiders/index' do
  it 'return all insiders' do
    create(:insider)
    get '/insiders'
    assert last_response.ok?
  end
end
