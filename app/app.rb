class App < Roda
  # plugin :h
  plugin :default_headers, 'Content-Type' => 'text/html; charset=UTF-8'
  plugin :class_matchers
  plugin :header_matchers
  plugin :symbol_matchers
  # plugin :public, root: 'static'
  plugin :multi_public, everyone_can_access: 'static', admin_can_access: 'admin_static'
  plugin :render, escape: true, layout: './layout'
  plugin :partials
  plugin :content_for
  plugin :view_options
  plugin :symbol_views
  plugin :json
  plugin :assets, css: ["app.scss"], js: ["app.js", "app1.js"]
  plugin :hash_routes
  compile_assets unless ENV["RACK_ENV"] == "development"

  route do |r|
    r.assets

    Dir["routes/**/*.rb"].each do |route_file|
      p File.expand_path(route_file)
      require File.expand_path(route_file)
    end

    r.hash_routes
    # r.on "search" do
    #   case q = r.params['q']
    #   when String
    #     ARTICLES.filter do |article|
    #       article.include?(q)
    #     end.join(" | ")
    #   else
    #     'Invalid'
    #   end
    # end

    # r.post 'articles' do
    #   ARTICLES << r.params['content']
    #   "Latest: #{ARTICLES.last} | Count: #{ARTICLES.count}"
    # end

    # r.get 'articles' do
    #   ARTICLES.join(' | ')
    # end

    # r.root do
    #   r.redirect "/posts"
    # end

    # r.get "posts" do
    #   posts = (0..5).map {|i| "Post #{i}"}
    #   posts.join(" | ")
    # end

    # r.is 'stocks' do
    #   stocks = Stock.association_join(:exchange).qualify.select_append(:exchange[:name].as(:exchange_name)).map do |x|
    #     [
    #       x[:id],
    #       x[:name],
    #       x[:exchange_name],
    #       x[:percent_of_institutions] ? "#{(x[:percent_of_institutions]*100).to_f}%" : ""
    #     ]
    #   end
    #   Thamble.table(stocks, headers: ['ID', '股票名称', '交易所名称', '机构持股占比'], widths: [50, 100, 100, 100])
    # end

    # r.on "posts" do
    #   binding.roda_path('in posts')
    #   r.on String do |seg|
    #     binding.roda_path('in inner String')
    #     "0 #{seg} #{r.remaining_path}"
    #   end
    # end

    # r.on String do |seg|
    #   binding.roda_path('in external String')
    #   "1 #{seg} #{r.remaining_path}"
    # end
  end
end

# Using this information and the the requests's path,
# it stores the part of the path that has yet to be routed,
# body                            # => "Also Allowed " 不对
# r.is true do == r.is do 以及 r.on true do == r.on do
#

# we need to we extract the data from the request
