class App
  hash_routes('insider_histories/index') do
    is true do |r|
      days = r.params['days'].presence || 7

      @log = Log.where(type: 'insider_parser').exclude(finished_at: nil).last

      sort_column, sort_direction, stock_name = r.params.values_at('sort_column', 'sort_direction', 'stock_name')

      sort_column = sort_column.presence || :date
      sort_direction = sort_direction.presence || :desc

      result = RetrieveInsiderHistory.call(
        days: days,
        sort_column:
        sort_column, sort_direction:
        sort_direction,
        stock_name: stock_name
      )

      @error_message = result.message if result.failure?
      @insider_histories = result.insider_histories || []

      r.html do
        view 'insider_histories/index'
      end
    end
  end
end
