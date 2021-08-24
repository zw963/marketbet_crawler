require 'test_helper'

describe 'test /stocks' do
  it 'test /stocks return a stock lists' do
    exchange = Exchange.create(name: 'nyse')
    create(:stock, name: 'ge', exchange: exchange, percent_of_institutions: 0.5525, id: 1)
    create(:stock, name: 'lu', exchange: exchange, percent_of_institutions: 0.2233, id: 2)

    get "/stocks"

    last_response.body.must_equal <<~'HEREDOC'
      <!doctype html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
          <title>  Stock list
      </title>
          <link rel="stylesheet" type="text/css" href="/assets/app-229e34816dcaa860ccefb78c1330f69e9711c10bc3d8c6b7afa8d2190618d249.css">
        </head>
        <body>
          <div id="app">
          </div>
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
        <td><a href="/stocks/1">ge</a></td>
        <td>nyse</td>
        <td>55.25%</td>
      </tr>
      <tr>
        <td>2</td>
        <td><a href="/stocks/2">lu</a></td>
        <td>nyse</td>
        <td>22.33%</td>
      </tr>

        </tbody>
      </table>





          <script src="/assets/app-a5f51ebadef35e028257569d3c92d3c4b89613a2f3b002addc11ceeb2dffcd90.js" type="text/javascript"></script>
          <script> Opal.loaded(typeof(OpalLoaded) === "undefined" ? [] : OpalLoaded); Opal.require("app"); </script>
            We have 2 stocks.

        </body>
      </html>
    HEREDOC
  end

  it 'test /stocks.json return json' do
    exchange = Exchange.create(name: 'nyse')
    Stock.create(name: 'ge', exchange: exchange, percent_of_institutions: 0.5525)
    Stock.create(name: 'lu', exchange: exchange, percent_of_institutions: 0.2233)

    get "/stocks.json"

    last_response.body.must_equal "[{\"id\":1,\"name\":\"ge\",\"exchange_id\":1,\"percent_of_institutions\":\"0.5525e0\",\"exchange_name\":\"nyse\"},{\"id\":2,\"name\":\"lu\",\"exchange_id\":1,\"percent_of_institutions\":\"0.2233e0\",\"exchange_name\":\"nyse\"}]"
  end
end
