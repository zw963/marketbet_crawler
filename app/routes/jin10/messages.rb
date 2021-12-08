class App < Roda
  hash_routes('jin10/latest_messages') do
    is true do |r|
      result = RetrieveJin10Message.result(r.params)

      @error_message = result.message if result.failure?

      @messages = result.messages

      r.html do
        view 'jin10/messages'
      end
    end
  end
end
