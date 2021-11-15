class App < Roda
  plugin :default_headers,
    'Content-Type' => 'text/html; charset=UTF-8',
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'
  plugin :render, escape: true, views: 'app/views'
  plugin :content_for
  plugin :partials
  plugin :path
  plugin :status_handler
  status_handler(404) do
    @error_message ||= "404"
    view('error')
  end
  plugin :delete_empty_headers
  plugin :public, gzip: true, brotli: true

  plugin :enhanced_logger if ENV['RACK_ENV'] == 'development'

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

  Dir['app/routes/**/*.rb', 'app/helpers/**/*.rb'].each do |file|
    load file
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

      r.is 'add-ts-keyword' do
        puts '*'*50 + 'Updating ts keyword' + '*'*50
        new_keyword = r.params['new_keyword']
        DB.run("INSERT INTO zhparser.zhprs_custom_word values('#{new_keyword}') ON CONFLICT DO NOTHING;")
        DB.run("SELECT sync_zhprs_custom_word();")
        DB.run("UPDATE investing_latest_news SET source = source, title = title;")
        r.redirect request.referrer
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

      r.is 'latest-insider-histories' do
        r.hash_routes('insider_histories/index')
      end

      r.on 'insiders' do
        r.is do
          r.hash_routes('insiders/index')
        end

        r.on Integer do |id|
        @insider = Insider[id]

        r.hash_routes('insiders/show')
      end
      end

      r.is 'latest-institutions' do
        r.hash_routes('institutions/index')
      end

      r.is 'investing-latest-news' do
        r.hash_routes('investings/latest_news')
      end
    end
  end
end
