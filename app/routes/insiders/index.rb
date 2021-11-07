class App
  hash_routes('insiders/index') do
    is true do |r|
      days = r.params['days'].presence || 7

      @log = Log.last(type: 'insider_parser')

      sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

      sort_column = sort_column.presence || :date
      sort_direction = sort_direction.presence || :desc

      result = RetrieveInsider.call(days: days, sort_column: sort_column, sort_direction: sort_direction)

      if result.success?
        @insiders = result.insiders
        view 'insiders/index'
      else
        @error_message = result.message
        @error_message = "#{@error_message} 最后一次爬虫时间为: #{@log.finished_at}" if @log.present?
        r.halt
      end
    end
  end
end
