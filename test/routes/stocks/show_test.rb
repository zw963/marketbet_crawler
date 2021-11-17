require 'test_helper'

describe '/stocks/1' do
  it 'should route to routes/stokcs/show' do
    stock = create(:stock, id: 1)
    get '/stocks/1'
    refute last_response.ok?
    create(:institution, stock: stock)
    get '/stocks/1'
    assert last_response.ok?
  end
end
