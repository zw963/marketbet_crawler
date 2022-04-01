require 'test_helper'

describe 'investing lastest news' do
  it 'should return correct public time string' do
    news = create(
      :investing_latest_news,
      publish_time_string: '30 分钟前',
      publish_time:        '2021-11-15 21:15:20'
    )
    Timecop.freeze('2021-11-15 21:45:10')
    assert_equal '21:15', news.display_time.to_s
    Timecop.freeze('2021-11-16 22:00:10')
    assert_equal '2021-11-15', news.display_time.to_s
  end
end
