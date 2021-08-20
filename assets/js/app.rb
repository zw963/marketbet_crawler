require 'opal'
require 'snabberb'

require 'native'
require 'promise'
require 'browser/setup/large'
require 'browser/http'

require_tree './components'

require 'opal-parser'
require 'js/bin/materialize'

$document.ready do
  # TextBox.attach('app', text: 'hello world')
  eval "puts 'hello world!'"
end

# p 100.class
