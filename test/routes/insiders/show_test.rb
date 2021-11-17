require 'test_helper'

describe 'routes/insiders/show' do
  it 'show insider' do
    insider = create(:insider, id: 1)
    get '/insiders/1'
    refute last_response.ok?
    create(:insider_history, insider: insider)
    get '/insiders/1'
    assert last_response.ok?
  end
end
