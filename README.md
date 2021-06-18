## An attempt to build a project using roda and sequel toolkit.

For scrap the public stocks data in marketbet.com, and show them.

## Technology stack

[Roda](https://github.com/jeremyevans/roda)

[Sequel](https://github.com/jeremyevans/sequel)

[hot_reloader](https://github.com/zw963/hot_reloader)

[ferrum](https://github.com/rubycdp/ferrum)

[puma](https://github.com/puma/puma)

Test driven by [rack-test](https://github.com/rack/rack-test)

## Folder structure

This project was adoption some devise from [roda adviced conventions](https://github.com/jeremyevans/roda/blob/master/doc/conventions.rdoc) partially, but not following it completely.

### config/environment.rb
this is the start point if you want start up app entirely as does like `rails c` in rails.
we adoption this filename because it more conveniently follow rails entry convertion.

e.g. you can add `require_relative 'config/environment'` into PROJECT_ROOT/.pryrc.

then run `pry` to start it.

we provide a conveniently command for start our app with irb too, live in `bin/irb`.

### config/application.rb

It is the place application config live, `config/environment.rb` require it, it require `config/models`.

With whatever you want put here for application specified config.

### config/models.rb

This is the place Sequel(ORM) config live, it require `config/db.rb` which create 
a new DB connection when start up, you can add whatever Sequel specified config here.

When run sequel rake tasks(e.g. rake db:migrate) defined in lib/tasks/sequel.rake, 
those task only require this file instead of require app entirely.

there is a command named `bin/db_console`, it require this file only too, with this, 
you can play with all models, but not need load app entirely.

### config/db.rb

Create Sequel db connection, we require this in test/test_helper, for check if current migration is latest.

### config/hot_reloader.rb

Require by others components for support auto reloader(development mode) and eagerload(in production).

### How to start app.

start app is easy.

1. ensure set correct `RACK_ENV` environment variable.
2. run `bundle exec puma` to start app.
3. if you use `foreman` like tools, you can start use it too.

### How to TDD

Just run `rake`.





