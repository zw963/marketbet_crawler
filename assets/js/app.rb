require 'opal'
require 'snabberb'

require_tree './components'
require 'lib/request'

puts 'hello'

Request.send('/stocks', 'get')

# TextBox.attach('app', text: 'hello world')
