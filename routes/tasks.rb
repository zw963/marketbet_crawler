class App
  hash_routes.on "tasks" do |r|
    r.get true do
      @tasks = Task.all
      view "index"
    end

    r.get Integer do |id|
      next unless @task = Task[id]

      view "task"
    end
  end
end
