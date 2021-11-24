class App
  hash_routes('firms/show') do
    is true do |r|
      result = RetrieveInstitutionHistory.result(**r.params, firm_id: @firm.id)

      if result.success?
        @institution_histories = result.institution_histories
      else
        @error_message = result.message
        @error_message = "#{@error_message} 最后一次爬虫时间为: #{@log.finished_at}" if @log.present?
        r.halt
      end

      view 'firms/show'
    end
  end
end
