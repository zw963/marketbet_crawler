trap(:QUIT) {
  t = Thread.list.first
  puts "#" * 90
  p t
  puts t.backtrace
  puts "#" * 90
}

require 'bundler'

require_relative 'load_env'
# 在生产环境, 添加export BUNDLE_WITHOUT=development:test, 来跳过所有不需要的 gem
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))

require_relative 'model'
load "#{APP_ROOT}/app/parsers/parser_base.rb"
Dir["#{APP_ROOT}/app/parsers/**/*.rb"].each {|m| load m }
Dir["#{APP_ROOT}/app/models/**/*.rb"].each {|m| load m }

require "capybara/cuprite"
Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  options = {
    pending_connection_errors: false,
    window_size: [1600, 900],
    process_timeout: 15,
    browser_options: { 'no-sandbox': nil, 'blink-settings' => 'imagesEnabled=false', 'start-maximized': true},
    headless: true,
  }

  if ENV['RACK_ENV'] == 'development'
    options.update(
      headless: true,
      slowmo: 0.5
    )
  end

  Capybara::Cuprite::Driver.new(
    app,
    **options
  )
end

# Capybara.default_max_wait_time = 10
