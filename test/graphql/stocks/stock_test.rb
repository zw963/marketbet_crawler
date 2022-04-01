require 'test_helper'

describe 'test graphql start to work' do
  it 'test graphql start to work' do
    exchange = create(:exchange, name: 'nyse')
    create(:stock, name: 'ge', exchange: exchange)

    post('/graphql.json', {query: query}.to_json)

    stock = content.data.stock
    assert_equal 'ge', stock.name
    assert_equal 'nyse', stock.exchangeName
  end
end
