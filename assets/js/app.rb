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
    %x{
var elems = document.querySelectorAll('.stock-complete');
var instances = M.Autocomplete.init(elems, {"data": #{json.to_n}});
    }
  end

  change_institution_display_name_callback = proc do |_, trigger|
    form = $document.at_css('#modal1 form')
    form.action = "/institutions/#{`trigger.dataset.institutionId`}"
    form.at_css('input').value = `trigger.dataset.institutionName`
    form.at_css('h4').text = '修改机构信息'
  end

  open_dropdown_callback = proc do |dropdown_trigger|
    a_eles = $document.css('#dropdown1 li a')
    a_eles[0]['href'] = `dropdown_trigger.href`
    a_eles[0].text = '查看机构信息'
    a_eles[1]['data-institution-id'] = `dropdown_trigger.dataset.InstitutionId`
    a_eles[1]['data-institution-name'] = `dropdown_trigger.innerText`
    a_eles[1].text = '修改名称备注'
  end

  %x{
var elems = document.querySelectorAll('.modal');
var instances = M.Modal.init(elems, {"onOpenStart": #{change_institution_display_name_callback.to_n}});

var elems = document.querySelectorAll('.dropdown-trigger');
var instances = M.Dropdown.init(elems, {"onOpenStart": #{open_dropdown_callback.to_n}});

var elems = document.querySelectorAll('.tooltipped');
var instances = M.Tooltip.init(elems, {"enterDelay": 1000});
  }
end
