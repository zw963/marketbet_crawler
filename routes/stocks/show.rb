class App
  hash_routes('stocks/show') do
    is true do |r|
      sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

      sort_column = sort_column.presence || :date
      sort_direction = sort_direction.presence || :desc

      @log1 = Log.last(type: 'institution_parser')
      result = RetrieveInstitutions.call(sort_column: sort_column, sort_direction: sort_direction, stock_id: @stock.id)

      cond1, cond2 = nil, nil

      if result.success?
        @institutions = result.institutions
      else
        @error_message = result.message
        @error_message = "#{@error_message}，机构最后一次爬虫时间为: #{@log1.finished_at}" if @log1.present?
        cond1 = true
      end

      @log2 = Log.last(type: 'insider_parser')
      result = RetrieveInsider.call(sort_column: sort_column, sort_direction: sort_direction, stock_id: @stock.id)

      if result.success?
        @insiders = result.insiders
      else
        # @error_message = result.message
        @error_message = "#{@error_message} 内幕交易最后一次爬虫时间为: #{@log2.finished_at}" if @log2.present?
        cond2 = true
      end

      if cond1 && cond2
        r.halt
      else
        view 'stocks/show'
      end
    end
  end
end
