FinnhubRuby.configure do |config|
  config.api_key['api_key'] = ENV.fetch('FINNHUB_API_KEY')
end
