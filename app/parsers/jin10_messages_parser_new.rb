class Jin10MessagesParserNew < ParserBase
  # 匹配这些中文标点符号 。 ？ ！ ， 、 ； ： “ ” ‘ ' （ ） 《 》 〈 〉 【 】 『 』 「 」 ﹃ ﹄ 〔 〕 … — ～ ﹏ ￥
  # 外加白空格 和 /
  CHINESE_PUNCTUATION_MARKS_REGEX = %r{\u3002|\uff1f|\uff01|\uff0c|\u3001|\uff1b|\uff1a|\u201c|\u201d|\u2018|\u2019|\uff08|\uff09|\u300a|\u300b|\u3008|\u3009|\u3010|\u3011|\u300e|\u300f|\u300c|\u300d|\ufe43|\ufe44|\u3014|\u3015|\u2026|\u2014|\uff5e|\ufe4f|\uffe5|\s+|/}

  def parse
    log = Log.create(type: 'jin10_latest_messages_parser')

    proc do
      url = 'https://www.jin10.com'

      logger.warn "visiting #{url}"

      browser.goto url

      sleep 2 while browser.css('ul.classify-list li').count < 2

      logger.warn "visit #{url} done"

      jin_flash_list = browser.at_css('#jin_flash_list')

      loop do
        begin
          jin_flash_date = jin_flash_list.at_css('.jin-flash-date-line.is-first')
          date = Date.strptime(jin_flash_date.text.strip, '%m月%d日')

          sleep 2 until (first_flash_message = jin_flash_date.at_xpath('./following-sibling::div'))

          is_important = first_flash_message.attribute('class').include?('is-important')
          time = first_flash_message.at_css('.item-time').text
          item = first_flash_message.at_css('.item-right')

          if (content = item.at_css('.right-content'))
            text = content.text.gsub(/\s/, '')

            if (link = item.at_css('.right-top .flash-remark a'))
              message_url = link.attribute('href')
            end

            if (image_link = item.at_css('.right-top .right-pic img'))
              image_url = image_link.attribute('src')
            end

            logger.info "Get message url: #{message_url}" if message_url.present?

            if text.start_with?('【')
              keyword = text[/【(.*)】.*/, 1]
              tag = Jin10MessageTag.find_or_create(name: keyword) if not keyword.match? CHINESE_PUNCTUATION_MARKS_REGEX and keyword.size < 8
            end

            next sleep 30 if text.blank?

            record = Jin10Message.find(
              title:        text,
              publish_date: date
            )

            if record.present?
              logger.info "title: #{text} is exists, skipped."
              next sleep 30
            end

            new_record = {
              title:               text,
              keyword:             keyword || '',
              tag:                 tag,
              publish_date:        date,
              publish_time_string: time,
              important:           is_important,
              url:                 message_url.to_s,
              image_url:           image_url.to_s
            }

            Jin10Message.create(new_record)

            logger.info "created record: #{text}"
          end
        end

        sleep 90
      end
    rescue Ferrum::NodeNotFoundError => e
      logger.warn 'jin10 message node get updated while scraping, retrying...'
      puts e.full_message if ENV['debug'] == true
      sleep 2
      retry
    end => message_parser_proc

    retry_until_timeout 7200, message: 'Refresh again', keep_waiting_if: message_parser_proc
  ensure
    log.update(finished_at: Time.now)
  end
end
