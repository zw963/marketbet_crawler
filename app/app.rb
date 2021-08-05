class App < Roda
  plugin :default_headers, 'Content-Type' => 'text/html; charset=UTF-8'
  plugin :render, escape: true
  plugin :content_for
  plugin :partials
  plugin :path

  route do |r|
    r.get 'stocks' do
      sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

      if sort_column.present?
        order = case sort_column
                when /^(id|name|percent_of_institutions)$/
                  :stocks[sort_column.to_sym]
                when /^exchange_name$/
                  :exchange[:name]
                end
      end

      if sort_direction == 'desc'
        order = order.desc
      end

      @stocks = Stock.association_join(:exchange).qualify.select_append(:exchange[:name].as(:exchange_name)).order(order)
      view 'stocks/index', locals: {sort_column: sort_column, sort_direction: sort_direction}
    end
  end

  # 第一次运行，生成的 url 是：<a href="/stocks/order_by=id&sort_direction=desc">
  # 新的页面，会使用 stocks_path, 来生成所需的 link.
  # 此时：

  path :stocks_link do |title, current_column, sort_column, sort_direction|
    direction = current_column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    query_string = URI.encode_www_form(sort_column: current_column, sort_direction: direction)
    href = "/stocks"
    href = "#{href}?#{query_string}" if query_string.present?
    "<a href=\"#{href}\">#{title}</a>"
  end
end
