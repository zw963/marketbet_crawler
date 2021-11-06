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
      form = $document.at_css('#modal1 form')
      form.action = "/firms/#{`trigger.dataset.firmId`}"
      form.at_css('input').value = `trigger.dataset.firmName`
      form.at_css('h4').text = '修改机构信息'
    end

    open_dropdown_callback = proc do |dropdown_trigger|
      a_eles = $document.css('#dropdown1 li a')
      a_eles[0]['href'] = `dropdown_trigger.href`
      a_eles[0].text = '查看机构信息'
      a_eles[1]['data-firm-id'] = `dropdown_trigger.dataset.firmId`
      a_eles[1]['data-firm-name'] = `dropdown_trigger.innerText`
      a_eles[1].text = '修改名称备注'
    end

    %x{
var elems = document.querySelectorAll('.autocomplete');
var instances = M.Autocomplete.init(elems, {"data": #{json.to_n}});

var elems = document.querySelectorAll('.modal');
var instances = M.Modal.init(elems, {"onOpenStart": #{change_firm_display_name_callback.to_n}});

var elems = document.querySelectorAll('.dropdown-trigger');
var instances = M.Dropdown.init(elems, {"onOpenStart": #{open_dropdown_callback.to_n}});

var elems = document.querySelectorAll('.tooltipped');
var instances = M.Tooltip.init(elems, {"enterDelay": 1000});
    }
  end
end
