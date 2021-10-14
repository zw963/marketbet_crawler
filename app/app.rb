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

  plugin :hash_routes

  Dir["routes/**/*.rb"].each do |route_file|
    load route_file
  end

  route do |r|
    r.public
    r.sprockets if ENV['RACK_ENV'] == 'development'

    r.root do
      view 'index'
    end

    r.post do
      r.is 'graphql' do
        r.hash_routes('graphql')
      end

      r.is 'firms', Integer do |id|
        @id = id
        r.hash_routes('firms/update')
      end
    end

    r.get do
      r.on 'stocks' do
        r.is do
          r.hash_routes('stocks/index')
        end

        r.on Integer do |id|
          @stock = Stock[id]

          r.hash_routes('stocks/show')
        end
      end

      r.is 'firms', Integer do |id|
        @firm = Firm[id]

        r.hash_routes('firms/show')
      end

      r.is 'latest-insiders' do
        r.hash_routes('insiders/index')
      end

      r.is 'latest-institutions' do
        r.hash_routes('institutions/index')
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

  path :page do |page, title, page_size=10|
    params = request.params.dup
    query_string = URI.encode_www_form(params.merge({'page' => page, 'per' => page_size}))
    href = request.path
    href = "#{href}?#{query_string}" if query_string.present?
    anchor_class = "waves-effect waves-light btn-small"
    anchor_class = "#{anchor_class} disabled" if page.nil?
    "<a class=\"#{anchor_class}\" href=\"#{href}\">#{title}</a>"
  end
end
