class Request
  def self.send(path, method, data, prefix, block) # rubocop:disable Lint/UnusedMethodArgument
    data = data&.merge(_client_id: `MessageBus.clientId`)

    %x{
        var payload = {
          method: #{method},
          headers: {
            'Content-Type': 'application/json',
          }
        }
        if (method == 'POST') {
          payload['body'] = JSON.stringify(#{data.to_n})
        }
        if (typeof fetch !== 'undefined') {
          fetch(#{prefix + path}, payload).then(res => {
            return res.text()
          }).catch(error => {
            if (typeof block === 'function') {
              block(Opal.hash('error', JSON.stringify(error)))
            }
          })
        }
    }
  end
end
