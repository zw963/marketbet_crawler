class App::Mailer < Roda
  plugin :mailer

  route do |r|
    r.on "tasks", Integer do |id|
      no_mail! unless @task = Task[id]

      from "root@zw963.online"
      to "zw963@163.com"

      r.mail "updated" do
        subject "Task ##{id} Updated."
        "Task #{@task.title} has been updated!"
      end
    end
  end
end
