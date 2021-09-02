require 'opal'
require 'js/bin/materialize'

require 'native'
require 'promise'
require 'browser/setup/mini'
require 'browser/http'

# require 'snabberb'
# require_tree './components'

# require 'opal-parser'


def get_json(path)
  promise = Promise.new

  Browser::HTTP.get(path) do
    on :success do |res|
      promise.resolve res.json
    end
  end

  promise
end

$document.ready do
  get_json('/stocks.json').then do |json|
    %x{
        var elems = document.querySelectorAll('.autocomplete');
        var instances = M.Autocomplete.init(elems, {"data": #{json.to_n}});
    }
  end
end
