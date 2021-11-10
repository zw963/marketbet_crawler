class App
  hash_routes('insiders/index') do
    is true do |r|
      sort_column, sort_direction, name, page, per = r.params.values_at('sort_column', 'sort_direction', 'name', 'page', 'per')

      result = RetrieveInsiders.(
        sort_column: sort_column,
        sort_direction: sort_direction,
        page: page,
        per: per,
        name: name
      )

      if result.success?
        @insiders = result.insiders

        r.html do
          view 'insiders/index'
        end
      else
        @error_message = result.message
        r.halt
      end
    end
  end
end
