require 'test_helper'

describe 'retrieve latest institution histories' do
  it 'get the expected insider list' do
    Timecop.freeze('2021-08-14')
    assert_equal 0, InsiderHistory.all.count

    exchange = create(:exchange, name: 'nyse')
    stock = create(:stock, name: 'nyse/ge', exchange: exchange, id: 1)
    create(:insider_history, stock: stock, date: '2021-08-14', created_at: '2021-08-04')
    create(:insider_history, stock: stock, date: '2021-08-13')
    create(:insider_history, stock: stock, date: '2021-08-12')
    create(:insider_history, stock: stock, date: '2021-08-11', created_at: '2021-08-04')
    create(:insider_history, stock: stock, date: '2021-08-10', created_at: '2021-08-04')
    create(:insider_history, stock: stock, date: '2021-08-09')

    assert_equal 6, InsiderHistory.all.count
    result = RetrieveInsiderHistory.call(days: 3)
    assert_predicate result, :success?
    insider_histories = result.insider_histories
    assert_equal ['2021-08-14', '2021-08-13', '2021-08-12', '2021-08-11', '2021-08-09'], (insider_histories.map {|x| x['日期'] })
    assert_equal({
                   '股票' => 'nyse/ge',
                   '日期' => '2021-08-14',
                   '职位' => 'Major Shareholder(大股东)',
                   '股票变动数量' => -220809,
                   '平均价格' => 1.92,
                   '交易价格' => 423953.28,
                   '创建时间' => '08-04 00:00',
                   '颜色' => 'red'
                 },
                 insider_histories.first.except('ID', '名称', 'stock_id', 'insider_id'))
  end
end
