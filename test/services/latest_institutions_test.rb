require 'test_helper'

describe "retrieve latest institutions" do
  it "get the expected institution list" do
    Timecop.freeze('2021-08-06')
    assert_equal 0, Institution.all.count

    exchange = create(:exchange, name: 'exchange')
    stock = create(:stock, name: 'stock', exchange: exchange, id: 1)
    firm1 = create(:firm)
    firm2 = create(:firm, display_name: '黑石_2')
    firm3 = create(:firm, display_name: '黑石_3')
    firm4 = create(:firm, display_name: '黑石_4')
    firm5 = create(:firm, display_name: '黑石_5', id: 5)
    create(:institution, date: '2021-08-02', created_at: '2021-08-04', name: 1, firm: firm1, stock: stock)
    create(:institution, date: '2021-08-03', created_at: '2021-08-04', name: 2, firm: firm2, stock: stock)
    create(:institution, date: '2021-08-04', created_at: '2021-08-04', name: 3, firm: firm3, stock: stock)
    create(:institution, date: '2021-08-05', created_at: '2021-08-04', name: 4, firm: firm4, stock: stock)
    create(:institution, date: '2021-08-02', name: 5, firm: firm5, stock: stock)
    assert_equal 5, Institution.all.count
    result = RetrieveInstitutions.call(days: 3, sort_column: 'stock_name')
    assert_equal true, result.success?
    institutions = result.institutions
    assert_equal ["黑石_2", "黑石_3", "黑石_4", "黑石_5"], (institutions.map {|x| x['机构名称'] })
    assert_equal({
      "股票"=>"exchange/stock",
      "stock_id" => 1,
      "日期"=>"2021-08-02",
      "机构名称"=>"黑石_5",
      "firm_id" => 5,
      "机构持有数量"=>69830,
      "市场价值"=>"94.0万($0.94M)",
      "占股票百分比"=>"2.4%",
      "占机构百分比"=>"2.0%",
      "机构季度变动百分比"=>"N/A",
      "机构季度变动数量"=>"N/A",
      "机构平均成本"=>0.0,
      "创建时间"=>"08-06 00:00"
    },
      institutions.last.except("ID"))
  end

  it "get the expected institution list" do
    Timecop.freeze('2021-08-06')
    assert_equal 0, Institution.all.count
    create(:institution, date: '2021-08-02', created_at: '2021-08-04', name: 1)

    assert_equal 1, Institution.all.count
    result = RetrieveInstitutions.call(days: 3)
    assert_equal false, result.success?
    assert_nil result.institutions
    assert_equal '没有最新的结果！', result.message
  end
end
