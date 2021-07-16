class App
  hash_routes.on "tasks" do |r|
    r.get do
      "tasks"
    end

    r.on Integer do |id|
      @id = id

      r.hash_routes(:task)
    end
  end
end
