class App < Roda
  plugin :default_headers, 'Content-Type' => 'text/html; charset=UTF-8'
  plugin :render, escape: true
  plugin :content_for
  plugin :partials
  plugin :path
  plugin :not_found do
    view('error', layout: false)
  end

  route do |r|
    r.is 'stocks' do
      r.get do
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

    r.is 'latest-institutions' do
      days = r.params['days'].presence || 30
      result = RetrieveLatestInstitutions.call(days: days.to_i)
      if result.success?
        @institutions = result.institutions
        view 'institutions/index'
      else
        @error_message = result.message
        r.halt
      end
    end
  end

  path :stocks_link do |title, current_column, sort_column, sort_direction|
    href = "/stocks"

    direction = (current_column == sort_column && sort_direction == 'desc') ? 'asc' : 'desc'
    query_string = URI.encode_www_form(sort_column: current_column, sort_direction: direction)
    href = "#{href}?#{query_string}" if query_string.present?

    "<a href=\"#{href}\">#{title}</a>"
  end
end
