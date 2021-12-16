class App < Roda
  hash_routes('jin10/latest_messages') do
    is true do |r|
      result = RetrieveJin10Message.result(r.params)

      @error_message = result.message if result.failure?

      @messages = result.messages

      @message_tags = Jin10MessageTag.select(:id, :name).naked.all

      r.html do
        view 'jin10/messages'
      end
    end
  end
end
