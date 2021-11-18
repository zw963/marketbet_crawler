class App
  hash_routes('institutions/index') do
    is true do |r|
      @log = Log.where(type: 'institution_parser').exclude(finished_at: nil).last

      days = r.params['days'].presence || (Date.today.monday? ? 3 : 1)

      result = RetrieveInstitutions.result(**r.params, 'days' => days)

      r.html do
        @institutions = result.institutions || []
        view 'institutions/index'
      end
    end
  end
end
