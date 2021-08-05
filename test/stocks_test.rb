require 'test_helper'

describe 'test /stocks' do
  it 'test /stocks return a stock lists' do
    exchange = Exchange.create(name: 'nyse')
    Stock.create(name: 'ge', exchange: exchange, percent_of_institutions: 0.5525)
    Stock.create(name: 'lu', exchange: exchange, percent_of_institutions: 0.2233)

    get "/stocks"

    last_response.body.must_equal <<-'HEREDOC'
<html>
  <head>
    <title>  Stock list
</title>
  </head>
  <body>
    <h1>  Stock list
</h1>
    <table>
  <thead>
    <tr>
      <th><a href="/stocks?sort_column=id&sort_direction=desc">ID</a></th>
      <th><a href="/stocks?sort_column=name&sort_direction=desc">股票名称</a></th>
      <th><a href="/stocks?sort_column=exchange_name&sort_direction=desc">交易所名称</a></th>
      <th><a href="/stocks?sort_column=percent_of_institutions&sort_direction=desc">机构持股占比</a></th>
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



      We have 2 stocks.

  </body>
</html>
HEREDOC
  end
end
