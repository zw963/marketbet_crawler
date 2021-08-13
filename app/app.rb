class App < Roda
  plugin :default_headers, 'Content-Type' => 'text/html; charset=UTF-8'
  plugin :render, escape: true
  plugin :content_for
  plugin :partials
  plugin :path
  plugin :status_handler
  status_handler(404) do
    @error_message ||= "404"
    view('error', layout: false)
  end
  status_handler(304) do
    response.headers['Content-Type'] = ''
  end
  plugin :delete_empty_headers
  plugin :public
  plugin :sprockets, precompile: ['app.rb', 'app.scss'],
  root: Dir.pwd,
  public_path: 'public/',
  opal: true,
  debug: ENV['RACK_ENV'] != 'production'

  route do |r|
    r.public
    r.sprockets

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
        view 'stocks/index'
      end
    end

    r.is 'latest-insiders' do
      days = r.params['days'].presence || 7

      @log = Log.last(type: 'insider_parser')

      result = RetrieveLatestInsider.call(days: days)

      if result.success?
        @insiders = result.insiders
        view 'insiders/index'
      else
        @error_message = result.message
        @error_message = "#{@error_message} 最后一次爬虫时间为: #{@log.finished_at}" if @log.present?
        r.halt
      end
    end

    r.is 'latest-institutions' do
      days = r.params['days'].presence || (Date.today.monday? ? 3 : 1)

      @log = Log.last(type: 'institution_parser')

      sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

      if sort_column.present?
        order = case sort_column
                when /^(id|stock_id|date|name)$/
                  :institutions[sort_column.to_sym]
                end
      end

      if sort_direction == 'desc'
        order = order.desc
      end

      result = RetrieveLatestInstitutions.call(days: days, order: order)
      if result.success?
        @institutions = result.institutions
        view 'institutions/index'
      else
        @error_message = result.message
        @error_message = "#{@error_message} 最后一次爬虫时间为: #{@log.finished_at}" if @log.present?
        r.halt
      end
    end
  end

  path :link do |href, title, current_column|
    params = request.params.dup
    sort_column = params.delete('sort_column')
    sort_direction = params.delete('sort_direction')
    direction = (current_column == sort_column && sort_direction == 'desc') ? 'asc' : 'desc'
    query_string = URI.encode_www_form(sort_column: current_column, sort_direction: direction, **params)
    href = "#{href}?#{query_string}" if query_string.present?

    "<a href=\"#{href}\">#{title}</a>"
  end
end
