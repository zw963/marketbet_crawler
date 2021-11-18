require 'test_helper'

describe '/stocks/1' do
  it 'should failed' do
    create(:stock, id: 1)
    get '/stocks/1'
    refute last_response.ok?
  end

  it 'should success' do
    stock = create(:stock, id: 1)
    create(:institution, stock: stock)
    get '/stocks/1'
    assert last_response.ok?
  end

  it 'should success' do
    stock = create(:stock, id: 1)
    create(:institution, stock: stock)
    create(:insider_history, stock: stock)
    get '/stocks/1'
    assert last_response.ok?
  end
end
