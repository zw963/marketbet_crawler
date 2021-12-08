require 'opal'
require 'js/bin/materialize'

require 'native'
require 'promise'
require 'browser/setup/mini'
require 'browser/http'

# require 'snabberb'
# require_tree './components'

# require 'opal-parser'

$document.ready do
  institution_history_dropdown()
  change_institution_display_name_modal_dialog()
  investing_latest_news_tips()
  get_stocks_json()
end


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

def get_stocks_json
  get_json('/stocks.json').then do |json|
    %x{
var elems = document.querySelectorAll('.stock-complete');
var instances = M.Autocomplete.init(elems, {"data": #{json.to_n}});
    }
  end
end

def institution_history_dropdown
  # 点开 dropdown 的时候执行
  callback = proc do |trigger|
    a_eles = $document.css('#dropdown1 li a')
    a_eles[0].text = '查看机构信息'
    a_eles[1].text = '修改名称备注'

    # set dropdown menu data
    a_eles[0]['href'] = `trigger.href`
    a_eles[1]['data-institution-id'] = `trigger.dataset.institutionId`
    a_eles[1]['data-institution-name'] = `trigger.innerText`
  end

  %x{
var elems = document.querySelectorAll('.institution-history-dropdown-trigger');
var instances = M.Dropdown.init(elems, {"onOpenStart": #{callback.to_n}});
  }
end

def change_institution_display_name_modal_dialog
  # 点击 “修改名称备注” 之后，创建 modal dialog 的时候执行.
  callback = proc do |_, trigger|
    form = $document.at_css('#modal1 form')
    form.action = "/institutions/#{`trigger.dataset.institutionId`}"
    form.at_css('input').value = `trigger.dataset.institutionName`
    form.at_css('h4').text = '修改机构信息'
  end
  %x{
var elems = document.querySelectorAll('.modal');
var instances = M.Modal.init(elems, {"onOpenStart": #{callback.to_n}});
  }
end

def investing_latest_news_tips
  %x{
var elems = document.querySelectorAll('.tooltipped');
var instances = M.Tooltip.init(elems, {"enterDelay": 1000});
  }
end
