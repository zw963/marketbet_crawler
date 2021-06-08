class App < Roda
  articles = ['programming ruby', 'programming rust']
  route do |r|
    r.post "articles" do
      articles << r.params["content"]
      "Count: #{articles.count}"
    end

    r.get "articles" do
      articles.join(', ')
    end
  end
end
