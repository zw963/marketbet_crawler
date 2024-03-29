require 'js/materialize'

require 'opal'
require 'promise'
require 'browser/setup/traditional'
require 'browser/http'

# requireg 'snabberb'
# require_tree './components'

# 这个用来支持 Opal.eval, 可以方便的在 browser console 调试 opal 代码。
# 这个只在调试的时候开启
# require 'opal-parser'

$document.ready do
  set_select_dropdown()
  set_tooltips()
  request_path = '/' + `location.pathname.substring(1)`
  puts request_path
  case request_path
  when %r{/stocks/\d+}, %r{/institutions/\d+}
    institution_history_dropdown()
    change_institution_display_name_modal_dialog()
  when '/stocks'
    get_stocks_json()
  when '/latest-insider-histories'
    get_stocks_json()
  when '/latest-institution-histories'
    get_stocks_json()
    institution_history_dropdown()
    change_institution_display_name_modal_dialog()
  when '/jin10-messages'
    label = $document.at_css("i#toggle_refresh_page_button").at_xpath("./following-sibling::label")
    `setInterval('window.location.reload()', 30000)` if label.text == '点击关闭自动刷新'
  end
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
    dropdown = $document.at_css('#dropdown1')
    dropdown.clear

    institution_id = `trigger.dataset.institutionId`
    institution_name = `trigger.innerText`
    institution_href = `trigger.href`

    DOM do
      li do
        a "查看机构信息", href: institution_href
      end
      li do
        a(
          "修改机构别名",
          "class" => 'modal-trigger',
          "href" => "#modal1",
          "data-institution-id" => institution_id,
          "data-institution-name" => institution_name
         )
      end
    end.append_to(dropdown)
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

def set_tooltips
  %x{
var elems = document.querySelectorAll('.tooltipped');
var instances = M.Tooltip.init(elems, {"enterDelay": 1000});
  }
end

def set_select_dropdown
  %x{
var elems = document.querySelectorAll('select');
  var instances = M.FormSelect.init(elems, {});
  }
end
