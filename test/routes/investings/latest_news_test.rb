require 'test_helper'

describe 'routes/investings/last_news' do
  it 'return investing news' do
    create(:investing_latest_news)
    get '/investing-latest-news'
    assert last_response.ok?
  end
end
