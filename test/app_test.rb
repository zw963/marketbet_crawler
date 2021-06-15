require 'test_helper'

class AppTest < Minitest::Test
  def test_stocks
    exchange = Exchange.create(name: 'nyse')
    Stock.create(name: 'ge', exchange: exchange)
    Stock.create(name: 'lu', exchange: exchange)
    get "/stocks"
    assert_equal <<-'HEREDOC', last_response.body
<table>
<colgroup>
<col width="10" />
<col width="20" />
<col width="100" />
<col width="10" />
</colgroup>
<thead>
<tr>
<th>ID</th>
<th>股票名称</th>
<th>交易所名称</th>
<th>机构持股占比</th>
</tr>
</thead>
<tbody>
<tr>
<td>1</td>
<td>ge</td>
<td>nyse</td>
<td></td>
</tr>
<tr>
<td>2</td>
<td>lu</td>
<td>nyse</td>
<td></td>
</tr>
</tbody>
</table>
HEREDOC
  end
end
