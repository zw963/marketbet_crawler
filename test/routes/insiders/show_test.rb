require 'test_helper'

describe 'routes/insiders/show' do
  it 'should failed' do
    create(:insider, id: 1)
    get '/insiders/1'
    refute_predicate last_response, :ok?
  end

  it 'should succss' do
    insider = create(:insider, id: 1)
    create(:insider_history, insider: insider)
    get '/insiders/1'
    assert_predicate last_response, :ok?
  end
end
