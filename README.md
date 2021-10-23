## An attempt to build a project using roda and sequel toolkit, for Simplicity, less gems.

For scrap the public stocks data in marketbet.com, and show them.

## Technology stack

[Roda](https://github.com/jeremyevans/roda) with plugins.

[Sequel](https://github.com/jeremyevans/sequel) with plugins.

[hot_reloader](https://github.com/zw963/hot_reloader)

[puma](https://github.com/puma/puma)

[minitest](https://github.com/seattlerb/minitest), ruby builtin.

[rack-test](https://github.com/rack/rack-test)

<!-- [ferrum](https://github.com/rubycdp/ferrum), for used with chrome headless. -->

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

### Rakefile, lib/tasks/sequel.rake

1. Add tasks for run tests in test/ folder. just run `rake` or `rake test`.
2. Add tasks for run specs in spec/ folder. run `rake spec`.
3. Add tasks for run sequel db tasks,  e.g. `rake db:migrate`

## How to start app.

1. run `bundle`
2. set environment variables:
   ```
   export DEVELOPMENT_DATABASE_URL="sqlite://db/files/marketbet_crawler_development.db"
   export TEST_DATABASE_URL="sqlite://db/files/marketbet_crawler_test.db"
   export DATABASE_URL="sqlite://db/files/marketbet_crawler_production.db"
   export APP_SESSION_SECRET="909f017cc94c96f8a1aff843d95920485376f4c997143cc3c39ca945c883ec88e310a2177a69b8b714d22af1b5fd7864833568b6bf93fc3bc811bcf6e112"
3. ```
3. set correct `DEVELOPMENT_DATABASE_URL`, `TEST_DATABASE_URL` environment variable.
4. run `rake db:migrate` if `db/migrations` any.
5. run `bundle exec puma` to start this app. (or use Procfile with forman/procodile)
