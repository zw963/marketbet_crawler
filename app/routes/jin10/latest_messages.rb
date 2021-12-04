class App < Roda
  hash_routes('jin10/latest_messages') do
    is true do |r|
      result = RetrieveJin10LatestMessages.result(r.params)

      @error_message = result.message if result.failure?
      @news = result.latest_messages

      r.html do
        view 'investings/latest_messages'
      end
    end
  end
end
