require 'test_helper'

describe 'retrieve investing latest news' do
  SETUP = begin
    DB.run(Sequel.lit('DELETE FROM zhparser.zhprs_custom_word;'))
    DB.run('SELECT sync_zhprs_custom_word();')
  end

  it 'should not find out "美元" ' do
    assert_equal 0, InvestingLatestNews.count

    create(:investing_latest_news,
           title:   'NYMEX原油仍有可能跌破78.85美元',
           preview: '周二(11月16日)，国际油价在疲软开局后反弹，因为对库存紧张的担忧支撑了价格，不过欧洲新冠病例回升后对需求的担忧限制了乐观情绪。技术上仍看跌，NYMEX原油仍有可能跌破78.8...')

    create(:investing_latest_news,
           title:   '荷兰皇家壳牌拟终止双重股份结构，并更改公司全名',
           preview: '智通财经APP获悉，荷兰皇家壳牌(AS:RDSa)计划精简其公司结构，建立单一股份结构，并将其纳税地点从荷兰迁至英国。\n尽管这样的变更多年来一直有可能发生，但壳牌做出这一决定之际，...')

    assert_equal 2, InvestingLatestNews.count

    result = RetrieveInvestingLatestNews.result(q: '美元')
    assert_empty result.news.map(&:title)
  end

  it 'ts should find out "美元" ' do
    if DB.in_transaction?
      skip '测试更新全文搜索关键字，不支持在 transaction 模式下运行'
    else
      assert_equal 0, InvestingLatestNews.count

      news1 = create(:investing_latest_news,
                     title:   'NYMEX原油仍有可能跌破78.85美元',
                     preview: '周二(11月16日)，国际油价在疲软开局后反弹，因为对库存紧张的担忧支撑了价格，不过欧洲新冠病例回升后对需求的担忧限制了乐观情绪。技术上仍看跌，NYMEX原油仍有可能跌破78.8...')

      create(:investing_latest_news,
             title:   '荷兰皇家壳牌拟终止双重股份结构，并更改公司全名',
             preview: '智通财经APP获悉，荷兰皇家壳牌(AS:RDSa)计划精简其公司结构，建立单一股份结构，并将其纳税地点从荷兰迁至英国。\n尽管这样的变更多年来一直有可能发生，但壳牌做出这一决定之际，...')

      first_time_updated_at = news1.reload.updated_at.to_s

      assert_equal 2, InvestingLatestNews.count

      result = RetrieveInvestingLatestNews.result(q: '美元')
      assert_empty result.news.map(&:title)

      header 'REFERER', '/'
      post '/add-ts-keyword', {'new_keyword' => '美元'}

      assert_predicate last_response, :redirect?

      sleep 1

      post '/sync-investing-latest-news-keyword'

      assert_predicate last_response, :redirect?

      second_time_updated_at = news1.reload.updated_at.to_s

      refute_equal first_time_updated_at, second_time_updated_at

      result = RetrieveInvestingLatestNews.result(q: '美元')
      assert_equal ['NYMEX原油仍有可能跌破78.85美元'], result.news.map(&:title)
    end
  end
end
