class App
  hash_routes('institutions/index') do
    is true do |r|
      days = r.params['days'].presence || (Date.today.monday? ? 3 : 1)

      @log = Log.last(type: 'institution_parser')

      sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

      sort_column = sort_column.presence || :stock_id
      sort_direction = sort_direction.presence || :desc

      result = RetrieveInstitutions.call(days: days, sort_column: sort_column, sort_direction: sort_direction)

      if result.success?
        @institutions = result.institutions
        view 'institutions/index'
      else
        @error_message = result.message
        @error_message = "#{@error_message} 最后一次爬虫时间为: #{@log.finished_at}" if @log.present?
        r.halt
      end
    end
  end
end
