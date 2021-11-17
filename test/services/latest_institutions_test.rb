require 'test_helper'

describe "retrieve latest institutions" do
  it "get the expected institution list" do
    Timecop.freeze('2021-08-06')
    assert_equal 0, Institution.all.count

    exchange = create(:exchange, name: 'nyse')
    stock = create(:stock, name: 'nyse/ge', exchange: exchange, id: 1)
    firm1 = create(:firm, id: 1)
    firm2 = create(:firm, display_name: '黑石_2', id: 2)
    firm3 = create(:firm, display_name: '黑石_3', id: 3)
    firm4 = create(:firm, display_name: '黑石_4', id: 4)
    firm5 = create(:firm, display_name: '黑石_5', id: 5)
    create(:institution, date: '2021-08-02', created_at: '2021-08-04', firm: firm1, stock: stock)
    create(:institution, date: '2021-08-03', created_at: '2021-08-04', firm: firm2, stock: stock)
    create(:institution, date: '2021-08-04', created_at: '2021-08-04', firm: firm3, stock: stock)
    create(:institution, date: '2021-08-05', created_at: '2021-08-04', firm: firm4, stock: stock)
    create(:institution, date: '2021-08-02', firm: firm5, stock: stock)
    assert_equal 5, Institution.all.count
    result = RetrieveInstitutions.call(days: 3, sort_column: 'firm_id', sort_direction: 'desc')
    assert_equal true, result.success?
    institutions = result.institutions
    assert_equal ["黑石_5", "黑石_4", "黑石_3", "黑石_2"], (institutions.map {|x| x['机构名称'] })
    assert_equal({
      "股票"=>"nyse/ge",
      "stock_id" => 1,
      "日期"=>"2021-08-03",
      "机构名称"=>"黑石_2",
      "firm_id" => 2,
      "机构持有数量"=>182902,
      "市场价值"=>"94.0万($0.94M)",
      "占股票百分比"=>"2.4%",
      "占机构百分比"=>"2.0%",
      "机构季度变动百分比"=>"1473.2%",
      "机构季度变动数量"=>171276,
      "机构平均成本"=>7.27,
      "创建时间"=>"08-04 00:00"
    },
      institutions.last.except("ID"))
  end

  it "get the expected institution list" do
    Timecop.freeze('2021-08-06')
    assert_equal 0, Institution.all.count
    create(:institution, date: '2021-08-02', created_at: '2021-08-04')

    assert_equal 1, Institution.all.count
    result = RetrieveInstitutions.call(days: 3)
    assert_equal false, result.success?
    assert_nil result.institutions
    assert_equal '没有最新的结果！', result.message
  end
end
