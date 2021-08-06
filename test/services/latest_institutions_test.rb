require 'test_helper'

describe "retrieve latest institutions" do
  it "get the expected institution list" do
    Timecop.freeze('2021-08-06')
    assert_equal 0, Institution.all.count

    create(:institution, date: '2021-08-02', created_at: '2021-08-04', name: 1)
    create(:institution, date: '2021-08-03', created_at: '2021-08-04', name: 2)
    create(:institution, date: '2021-08-04', created_at: '2021-08-04', name: 3)
    create(:institution, date: '2021-08-05', created_at: '2021-08-04', name: 4)
    create(:institution, date: '2021-08-02', name: 5)
    assert_equal 5, Institution.all.count
    result = RetrieveLatestInstitutions.call(days: 3)
    assert_equal true, result.success?
    assert_equal %w[2 3 4 5], result.institutions.map {|x| x['机构名称'] }
  end

  it "get the expected institution list" do
    Timecop.freeze('2021-08-06')
    assert_equal 0, Institution.all.count
    create(:institution, date: '2021-08-02', created_at: '2021-08-04', name: 1)

    assert_equal 1, Institution.all.count
    result = RetrieveLatestInstitutions.call(days: 3)
    assert_equal false, result.success?
    assert_nil result.institutions
    assert_equal '没有最新的结果！', result.message
  end
end
