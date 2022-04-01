require 'test_helper'

describe '/stocks/1' do
  it 'should failed' do
    create(:stock, id: 1)
    get '/stocks/1'
    refute_predicate last_response, :ok?
  end

  it 'should success' do
    stock = create(:stock, id: 1)
    create(:institution_history, stock: stock)
    get '/stocks/1'
    assert_predicate last_response, :ok?
  end

  it 'should success' do
    stock = create(:stock, id: 1)
    create(:institution_history, stock: stock)
    create(:insider_history, stock: stock)
    get '/stocks/1'
    assert_predicate last_response, :ok?
  end
end
