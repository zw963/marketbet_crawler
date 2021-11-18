class App
  hash_routes('insider_histories/index') do
    is true do |r|
      @log = Log.where(type: 'insider_parser').exclude(finished_at: nil).last

      result = RetrieveInsiderHistory.call(r.params)
      @error_message = result.message if result.failure?
      @insider_histories = result.insider_histories || []

      r.html do
        view 'insider_histories/index'
      end
    end
  end
end
