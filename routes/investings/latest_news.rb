class App
  hash_routes('investings/latest_news') do
    is true do |r|
      sort_column, sort_direction, page, per = r.params.values_at('sort_column', 'sort_direction', 'page', 'per')

      result = RetrieveInvestingLatestNews.call(
        sort_column: sort_column,
        sort_direction: sort_direction,
        page: page,
        per: per
      )

      if result.success?
        @news = result.news

        r.html do
          view 'investings/latest_news'
        end
      else
        @error_messsage = result.message
        r.halt
      end
    end
  end
end
