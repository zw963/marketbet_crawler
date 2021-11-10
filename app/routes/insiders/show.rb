class App
  hash_routes('insiders/show') do
    is true do |r|
      sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

      sort_column = sort_column.presence || :date
      sort_direction = sort_direction.presence || :desc

      result = RetrieveInsiderHistory.call(sort_column: sort_column, sort_direction: sort_direction, insider_id: @insider.id)

      if result.success?
        @insider_histories = result.insider_histories
      else
        @error_message = result.message
        r.halt
      end

      view 'insiders/show'
    end
  end
end
