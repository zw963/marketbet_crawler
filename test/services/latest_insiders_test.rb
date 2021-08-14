require 'test_helper'

describe "retrieve latest institutions" do
  it "get the expected insider list" do
    Timecop.freeze('2021-08-14')
    assert_equal 0, Insider.all.count

    exchange = create(:exchange, name: 'exchange')
    stock = create(:stock, name: 'stock', exchange: exchange)
    create(:insider, stock: stock, date: '2021-08-14', created_at: '2021-08-04')
    create(:insider, stock: stock, date: '2021-08-13')
    create(:insider, stock: stock, date: '2021-08-12')
    create(:insider, stock: stock, date: '2021-08-11', created_at: '2021-08-04')
    create(:insider, stock: stock, date: '2021-08-10', created_at: '2021-08-04')
    create(:insider, stock: stock, date: '2021-08-09')

    assert_equal 6, Insider.all.count
    result = RetrieveLatestInsider.call(days: 3)
    assert_equal true, result.success?
    insiders = result.insiders
    assert_equal ["2021-08-09", "2021-08-11", "2021-08-12", "2021-08-13", "2021-08-14"], insiders.map {|x| x['日期'] }
    assert_equal({
      "股票"=>"exchange/stock",
      "日期"=>"2021-08-14",
      "名称"=>"insider name 0",
      "职位"=> 'ceo',
      "股票变动数量"=>100,
      "平均价格" => 1.24,
      "交易价格" => 300.2,
      "创建时间" =>'08-04 00:00'
    },
      insiders.last.except("ID")
    )
  end
end
