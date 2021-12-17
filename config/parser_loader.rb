trap(:QUIT) {
  t = Thread.list.first
  puts "#" * 90
  p t
  puts t.backtrace
  puts "#" * 90
}

require 'bundler'

require_relative 'early_init'
# 在生产环境, 添加export BUNDLE_WITHOUT=development:test, 来跳过所有不需要的 gem
Bundler.require(:default, RACK_ENV)

require_relative 'model'
load "#{APP_ROOT}/app/parsers/parser_base.rb"
Dir["#{APP_ROOT}/app/parsers/**/*.rb"].each {|m| load m }
Dir["#{APP_ROOT}/app/models/**/*.rb"].each {|m| load m }

class ChromeHeadlessLogger
  def initialize(logger)
    @logger = logger
  end

  def puts(*args)
    @logger << (args)
  end
end

require "capybara/cuprite"
Capybara.register_driver(:cuprite) do |app|
  options = {
    # logger: ChromeHeadlessLogger.new(Logger.new('log/chrome_headless.log', 10, 1024000)),
    pending_connection_errors: false,
    window_size: [1600, 900],
    process_timeout: 15,
    browser_options: { 'no-sandbox': nil, 'blink-settings' => 'imagesEnabled=false', 'start-maximized': true},
    headless: true,
    slowmo: 0.25
  }

  if RACK_ENV == 'development'
    options.update(
      headless: false,
      slowmo: 0.5
    )
  end

  Capybara::Cuprite::Driver.new(
    app,
    **options
  )
end
Capybara.javascript_driver = :cuprite

# require 'capybara/apparition'
# Capybara.register_driver :apparition do |app|
#   Capybara::Apparition::Driver.new(app, options)
# end

# Capybara.register_driver(:apparition) do |app|
#   options = {
#     pending_connection_errors: false,
#     window_size: [1280, 1024],
#     process_timeout: 15,
#     # browser_options: { 'no-sandbox': nil, 'blink-settings' => 'imagesEnabled=false', 'start-maximized': true},
#     headless: true,
#     debug: true,
#     skip_image_loading: true
#   }

#   if RACK_ENV == 'development'
#     options.update(
#       headless: false,
#       slowmo: 0.5,
#       debug: true
#     )
#   end

#   Capybara::Apparition::Driver.new(
#     app,
#     **options
#   )
# end
# Capybara.javascript_driver = :apparition

# Capybara.default_max_wait_time = 10
