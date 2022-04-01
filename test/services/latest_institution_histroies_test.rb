require 'test_helper'

describe 'retrieve latest institution histories' do
  it 'get the expected institution history list' do
    Timecop.freeze('2021-08-06')
    assert_equal 0, InstitutionHistory.all.count

    exchange = create(:exchange, name: 'nyse')
    stock = create(:stock, name: 'nyse/ge', exchange: exchange, id: 1)
    institution1 = create(:institution, id: 1)
    institution2 = create(:institution, display_name: '黑石_2', id: 2, name: 'Name2')
    institution3 = create(:institution, id: 3, name: 'Name3')
    institution4 = create(:institution, display_name: '黑石_4', id: 4, name: 'Name4')
    institution5 = create(:institution, id: 5, name: 'Name5')
    create(:institution_history, date: '2021-08-02', created_at: '2021-08-04', institution: institution1, stock: stock)
    create(:institution_history, date: '2021-08-03', created_at: '2021-08-04', institution: institution2, stock: stock)
    create(:institution_history, date: '2021-08-04', created_at: '2021-08-04', institution: institution3, stock: stock)
    create(:institution_history, date: '2021-08-05', created_at: '2021-08-04', institution: institution4, stock: stock)
    create(:institution_history, date: '2021-08-02', institution: institution5, stock: stock)
    assert_equal 5, InstitutionHistory.all.count
    result = RetrieveInstitutionHistory.call(days: 3, sort_column: 'institution_id', sort_direction: 'desc')
    assert_predicate result, :success?
    institution_histories = result.institution_histories
    assert_equal [
      'Name5', '黑石_4', 'Name3', '黑石_2'
    ], (institution_histories.map {|x| x['机构名称'] })
    assert_equal({
                   '股票' => 'nyse/ge',
                   'stock_id' => 1,
                   '日期' => '2021-08-03',
                   '机构名称' => '黑石_2',
                   'institution_id' => 2,
                   '机构持有数量' => 182902,
                   '市场价值' => '94.0万($0.94M)',
                   '占股票百分比' => '2.4%',
                   '占机构百分比' => '2.0%',
                   '机构季度变动百分比' => '1473.2%',
                   '机构季度变动数量' => 171276,
                   '机构平均成本' => 7.27,
                   '创建时间' => '08-04 00:00',
                   '颜色' => 'green'
                 },
                 institution_histories.last.except('ID'))
  end

  it 'get the expected institution list' do
    Timecop.freeze('2021-08-06')
    assert_equal 0, InstitutionHistory.all.count
    create(:institution_history, date: '2021-08-02', created_at: '2021-08-04')

    assert_equal 1, InstitutionHistory.all.count
    result = RetrieveInstitutionHistory.result(days: 3)
    refute_predicate result, :success?
    assert_nil result.institution_histories
    assert_equal '没有最新的结果！', result.message
  end
end
