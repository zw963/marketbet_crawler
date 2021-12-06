require 'bundler'

require_relative 'load_env'
# 在生产环境, 添加export BUNDLE_WITHOUT=development:test, 来跳过所有不需要的 gem
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))

require_relative 'model'

loader = Zeitwerk::Loader.new
loader.push_dir("#{APP_ROOT}/app/parsers")
loader.push_dir("#{APP_ROOT}/app/models")
HotReloader.eager_load(loader)

require "capybara/cuprite"
Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  options = {
    pending_connection_errors: false,
    window_size: [1600, 900],
    timeout: 30,
    browser_options: { 'no-sandbox': nil, 'blink-settings' => 'imagesEnabled=false', 'start-maximized': true},
    headless: true,
  }

  if ENV['RACK_ENV'] == 'development'
    options.update(
      headless: true,
      slowmo: 0.25
    )
  end

  Capybara::Cuprite::Driver.new(
    app,
    **options
  )
end

# Capybara.default_max_wait_time = 10
