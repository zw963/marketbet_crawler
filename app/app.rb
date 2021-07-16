class App < Roda
  # plugin :h
  plugin :default_headers, {
    'Content-Type' => 'text/html; charset=UTF-8',
    # 'Strict-Transport-Security'=>'max-age=16070400;',
  }
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
  plugin :type_routing
  plugin :sessions, secret: "a692909f017cc94c96f8a1aff843d95920485376f4c997143cc3c39ca945c883ec88e310a2177a69b8b714d22af1b5fd7864833568b6bf93fc3bc811bcf6e112"
  plugin :route_csrf
  plugin :typecast_params

  load 'app/mailer.rb'

  Dir["routes/**/*.rb"].each do |route_file|
    load route_file
  end

  route do |r|
    r.assets
    # check_csrf!
    # r.hash_branches

    r.on "tasks", Integer do |id|
      r.is true do
        r.get do
          "tasks by #{id}"
        end

        r.post do
          Mailer.sendmail("/tasks/#{id}/updated")
          r.redirect
        end
      end
    end



    # r.get "tasks" do
    #   # "post tasks"
    #   @tasks = Task.all
    #   view('index')
    # end

    # r.post "add" do
    #   # item = typecast_params.nonempty_str!('item')
    #   # p item

    #   "success"
    # end

    # r.get "tasks" do |type|
    #   @tasks = Task.all

    #   r.html do
    #     view("index")
    #   end

    #   r.json do
    #     @tasks.map do |task|
    #       {id: task.id, name: task.title}
    #     end
    #   end
    # end

    # r.get /tasks(\.html|\.json)?/ do |type|
    #   @tasks = Task.all

    #   case type
    #   when nil, '.html'
    #     view("index")
    #   when '.json'
    #     @tasks.map do |task|
    #       {id: task.id, name: task.title}
    #     end
    #   end
    # end

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
