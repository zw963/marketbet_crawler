class App
  hash_routes('institution_histories/index') do
    is true do |r|
      @log = Log.where(type: 'institution_parser').exclude(finished_at: nil).last

      days = r.params['days'].presence || (Date.today.monday? ? 3 : 1)

      result = RetrieveInstitutionHistory.result(**r.params, 'days' => days)

      r.html do
        @institution_histories = result.institution_histories || []
        view 'institution_histories/index'
      end
    end
  end
end
