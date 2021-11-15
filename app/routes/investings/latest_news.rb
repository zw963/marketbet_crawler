class App
  hash_routes('investings/latest_news') do
    is true do |r|
      sort_column, sort_direction, page, per, q = r.params.values_at('sort_column', 'sort_direction', 'page', 'per', 'q')

      result = RetrieveInvestingLatestNews.(
        sort_column: sort_column,
        sort_direction: sort_direction,
        page: page,
        per: per,
        q: q
      )

      @error_message = result.message if result.failure?
      @news = result.news

      r.html do
        view 'investings/latest_news'
      end
    end
  end
end
