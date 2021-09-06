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

  # 其实 Browser::HTTP.get(path) 本身就返回一个 Promise,.
  Browser::HTTP.get(path) do
    on :success do |res|
      promise.resolve res.json
    end
  end

  promise
end

$document.ready do
  get_json('/stocks.json').then do |json|
    change_firm_display_name_callback = proc do |_, trigger|
      firm_id = `trigger.dataset.firmId`
      firm_name = `trigger.dataset.firmName`
      debugger
      p 'you click me!'
      form = $document.at_css('#modal1 form')
      form.action = "/firms/#{firm_id}"
      form.at_css('input').value = firm_name
    end

    %x{
var elems = document.querySelectorAll('.autocomplete');
var instances = M.Autocomplete.init(elems, {"data": #{json.to_n}});

var elems = document.querySelectorAll('.modal');
var instances = M.Modal.init(elems, {"onOpenStart": #{change_firm_display_name_callback.to_n}});
    }
  end
end
