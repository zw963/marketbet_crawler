class App < Roda
  # plugin :h
  plugin :default_headers, 'Content-Type' => 'text/html; charset=UTF-8'

  route do |r|
    r.is 'stocks' do
      headers = ['ID', '股票名称', '交易所名称', '机构持股占比']
      stocks = Stock.association_join(:exchange).qualify.select_append(:exchange[:name].as(:exchange_name)).map do |x|
        [
          x[:id],
          x[:name],
          x[:exchange_name],
          x[:percent_of_institution]
        ]
      end
      Thamble.table(stocks, headers: headers, widths: [10, 20, 100, 10])
    end
  end
end
