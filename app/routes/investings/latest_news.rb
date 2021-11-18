class App
  hash_routes('investings/latest_news') do
    is true do |r|
      result = RetrieveInvestingLatestNews.call(r.params)

      @error_message = result.message if result.failure?
      @news = result.news

      r.html do
        view 'investings/latest_news'
      end
    end
  end
end
