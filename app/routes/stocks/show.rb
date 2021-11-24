class App
  hash_routes('stocks/show') do
    is true do |r|
      @log1 = Log.last(type: 'institution_parser')
      params = {**r.params, stock_id: @stock.id}

      result = RetrieveInstitutionHistory.result(params)

      miss1, miss2 = nil, nil

      if result.success?
        @institution_histories = result.institution_histories
      else
        @error_message1 = "机构交易: finished at #{@log1.finished_at}" if @log1.present?
        miss1 = true
      end

      @log2 = Log.last(type: 'insider_parser')
      result = RetrieveInsiderHistory.result(params)

      if result.success?
        @insider_histories = result.insider_histories
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
