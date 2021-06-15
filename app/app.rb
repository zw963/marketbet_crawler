class App < Roda
  # plugin :h
  plugin :default_headers, 'Content-Type' => 'text/html; charset=UTF-8'

  route do |r|
    r.is 'stocks' do
      stocks = Stock.association_join(:exchange).qualify.select_append(:exchange[:name].as(:exchange_name)).map do |x|
        [
          x[:id],
          x[:name],
          x[:exchange_name],
          x[:percent_of_institutions] ? "#{x[:percent_of_institutions]*100}%" : ""
        ]
      end
    Thamble.table(stocks, headers: ['ID', '股票名称', '交易所名称', '机构持股占比'], widths: [50, 100, 100, 100])
    end
  end
end
