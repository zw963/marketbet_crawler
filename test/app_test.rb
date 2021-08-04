require 'test_helper'

class AppTest < Minitest::Test
  def test_stocks
    exchange = Exchange.create(name: 'nyse')
    Stock.create(name: 'ge', exchange: exchange, percent_of_institutions: 0.5525)
    Stock.create(name: 'lu', exchange: exchange, percent_of_institutions: 0.2233)
    get "/stocks"
    assert_equal <<-'HEREDOC', last_response.body
<table>
<colgroup>
<col width="50" />
<col width="100" />
<col width="100" />
<col width="100" />
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
<td>55.25%</td>
</tr>
<tr>
<td>2</td>
<td>lu</td>
<td>nyse</td>
<td>22.33%</td>
</tr>
</tbody>
</table>
HEREDOC
  end
end
