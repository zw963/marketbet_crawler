class App < Roda
  plugin :default_headers,
    'Content-Type' => 'text/html; charset=UTF-8',
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'
  plugin :render, escape: true
  plugin :content_for
  plugin :partials
  plugin :path
  plugin :status_handler
  status_handler(404) do
    @error_message ||= "404"
    view('error', layout: false)
  end
  plugin :delete_empty_headers
  plugin :public, gzip: true, brotli: true
  plugin :sprockets,
    opal: true,
    js_compressor: Terser.new,
    css_compressor: :sassc,
    cache: (Sprockets::Cache::MemoryStore.new(65536) if ENV['RACK_ENV'] == 'development')
  plugin :type_routing
  plugin :json

  route do |r|
    r.public
    r.sprockets if ENV['RACK_ENV'] == 'development'

    r.root do
      view 'index'
    end

    r.get do
      r.is 'stocks' do
        sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

        result = RetrieveStocks.call(sort_column: sort_column, sort_direction: sort_direction)

        if result.success?
          @stocks = result.stocks

          r.html do
            view 'stocks/index'
          end

          r.json do
            @stocks.map(&:to_hash)
          end
        else
          @error_message = result.message
          r.halt
        end
      end

      r.is 'latest-insiders' do
        days = r.params['days'].presence || 7

        @log = Log.last(type: 'insider_parser')

        sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

        sort_column = sort_column.presence || :date
        sort_direction = sort_direction.presence || :desc

        result = RetrieveLatestInsider.call(days: days, sort_column: sort_column, sort_direction: sort_direction)

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

        sort_column = sort_column.presence || :stock_id
        sort_direction = sort_direction.presence || :desc

        result = RetrieveLatestInstitutions.call(days: days, sort_column: sort_column, sort_direction: sort_direction)

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
