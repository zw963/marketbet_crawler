class InvestingLatestNewsParser < ParserBase
  def parse
    log = Log.create(type: 'investing_latest_news_parser')

    url = 'https://cn.investing.com/news/latest-news'
    puts url
    browser.goto url

    news_urls = browser.css('.largeTitle article.articleItem .textDiv').map do |e|
      [
        e.text,
        "https://cn.investing.com#{e.at_css('a').attribute('href')}"
      ]
    end

    news_urls.each do |text, url|
      next if InvestingLatestNews.find(url: url)

      title, source, publish_time, preview = text.scan(/(.*)提供者(.*) - (.*?(?:以前|\d+年\d+月\d+日))(.*)/m).flatten
      publish_time.strip!
      InvestingLatestNews.create(
        title:               title.strip,
        preview:             preview.strip,
        url:                 url,
        source:              source.strip,
        publish_time_string: publish_time,
        publish_time:        time2time(publish_time)
      )
    end

    log.update(finished_at: Time.now)
  end

  def time2time(chinese_time_string)
    if /(?<time_number>\d+)(?<time_unit>.*)以前/ =~ chinese_time_string
      case time_unit
      when /小时/
        Time.now - (time_number.to_i * 3600)
      when /分钟/
        Time.now - (time_number.to_i * 60)
      end
    else
      Date.strptime(chinese_time_string, '%Y年%m月%d日')
    end
  end
end
