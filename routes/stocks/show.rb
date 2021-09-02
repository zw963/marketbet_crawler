class App
  hash_routes('stocks/show') do
    is true do |r|
      sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

      sort_column = sort_column.presence || :date
      sort_direction = sort_direction.presence || :desc

      @log1 = Log.last(type: 'institution_parser')
      result = RetrieveInstitutions.call(sort_column: sort_column, sort_direction: sort_direction, stock_id: @stock.id)

      miss1, miss2 = nil, nil

      if result.success?
        @institutions = result.institutions
      else
        @error_message1 = "机构交易: finished at #{@log1.finished_at}" if @log1.present?
        miss1 = true
      end

      @log2 = Log.last(type: 'insider_parser')
      result = RetrieveInsider.call(sort_column: sort_column, sort_direction: sort_direction, stock_id: @stock.id)

      if result.success?
        @insiders = result.insiders
      else
        @error_message2 = "内幕交易: finished at #{@log2.finished_at}" if @log2.present?
        miss2 = true
      end

      if miss1 && miss2
        @error_message = result.message
        r.halt
      else
        view 'stocks/show'
      end
    end
  end
end
