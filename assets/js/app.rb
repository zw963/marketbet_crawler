require 'opal'
require 'snabberb'

require 'native'
require 'promise'
require 'browser/setup/full'
require 'browser/http'

require_tree './components'

Browser::HTTP.get "/stocks.json" do
  on :success do |res|
    puts res.json.inspect
  end
end

# TextBox.attach('app', text: 'hello world')
