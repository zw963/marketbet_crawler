class App
  hash_routes('institutions/index') do
    is true do |r|
      days = r.params['days'].presence || (Date.today.monday? ? 3 : 1)

      @log = Log.where(type: 'institution_parser').exclude(finished_at: nil).last

      sort_column, sort_direction, q = r.params.values_at('sort_column', 'sort_direction', 'q')

      sort_column = sort_column.presence || :date
      sort_direction = sort_direction.presence || :desc

      result = RetrieveInstitutions.call(days: days, sort_column: sort_column, sort_direction: sort_direction, stock_name: q)

      r.html do
        @institutions = result.institutions || []
        view 'institutions/index'
      end
    end
  end
end
