class App
  hash_routes('insiders/show') do
    is true do |r|
      result = RetrieveInsiderHistory.result(**r.params, insider_id: @insider.id)

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
