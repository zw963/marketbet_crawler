class App
  hash_routes('insiders/index') do
    is true do |r|
      result = RetrieveInsiders.result(r.params)

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
