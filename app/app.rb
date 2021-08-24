class App < Roda
  plugin :default_headers,
    'Content-Type' => 'text/html; charset=UTF-8'
    # 'X-Frame-Options'=>'deny',
    # 'X-Content-Type-Options'=>'nosniff',
    # 'X-XSS-Protection'=>'1; mode=block'
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
  cache = case ENV['RACK_ENV']
          when 'development'
            Sprockets::Cache::MemoryStore.new(65536)
          when 'test'
            Sprockets::Cache::FileStore.new("tmp/cache")
          end
  plugin :sprockets,
    opal: true,
    js_compressor: Terser.new,
    css_compressor: :sassc,
    cache: cache
  plugin :type_routing
  plugin :json

  route do |r|
    r.public
    r.sprockets if ENV['RACK_ENV'] == 'development'

    r.root do
      view 'index'
    end

    r.post do
      r.is 'graphql' do
        # query = r.params.fetch('query', '')
        load = JSON.load(r.body)

        r.json do
          ApplicationSchema.execute(load['query']).to_h
        end
      end
    end

    r.get do
      r.is 'stocks' do
        sort_column, sort_direction, page, per = r.params.values_at('sort_column', 'sort_direction', 'page', 'per')

        result = RetrieveStocks.call(sort_column: sort_column, sort_direction: sort_direction, page: page, per: per)

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

      r.is 'stocks', Integer do |id|
        @stock = Stock[id]
        sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

        sort_column = sort_column.presence || :date
        sort_direction = sort_direction.presence || :desc

        result = RetrieveInstitutions.call(sort_column: sort_column, sort_direction: sort_direction, stock_id: id)

        if result.success?
          @institutions = result.institutions
        else
          @error_message = result.message
          @error_message = "#{@error_message} 最后一次爬虫时间为: #{@log.finished_at}" if @log.present?
          r.halt
        end

        result = RetrieveInsider.call(sort_column: sort_column, sort_direction: sort_direction, stock_id: id)

        if result.success?
          @insiders = result.insiders
        else
          @error_message = result.message
          @error_message = "#{@error_message} 最后一次爬虫时间为: #{@log.finished_at}" if @log.present?
          r.halt
        end

        view 'stocks/show'
      end

      r.is 'firms', Integer do |id|
        @firm = Firm[id]
        sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

        sort_column = sort_column.presence || :date
        sort_direction = sort_direction.presence || :desc

        result = RetrieveInstitutions.call(sort_column: sort_column, sort_direction: sort_direction, firm_id: id)

        if result.success?
          @institutions = result.institutions
        else
          @error_message = result.message
          @error_message = "#{@error_message} 最后一次爬虫时间为: #{@log.finished_at}" if @log.present?
          r.halt
        end

        view 'firms/show'
      end

      r.is 'latest-insiders' do
        days = r.params['days'].presence || 7

        @log = Log.last(type: 'insider_parser')

        sort_column, sort_direction = r.params.values_at('sort_column', 'sort_direction')

        sort_column = sort_column.presence || :date
        sort_direction = sort_direction.presence || :desc

        result = RetrieveInsider.call(days: days, sort_column: sort_column, sort_direction: sort_direction)

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

        result = RetrieveInstitutions.call(days: days, sort_column: sort_column, sort_direction: sort_direction)

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

  path :link do |title, current_column|
    params = request.params.dup
    sort_column = params.delete('sort_column')
    sort_direction = params.delete('sort_direction')
    direction = (current_column == sort_column && sort_direction == 'desc') ? 'asc' : 'desc'
    query_string = URI.encode_www_form(sort_column: current_column, sort_direction: direction, **params)
    href = request.path
    href = "#{href}?#{query_string}" if query_string.present?
    "<a href=\"#{href}\">#{title}</a>"
  end
end
