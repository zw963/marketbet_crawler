class Jin10MessagesParser < ParserBase
  # 匹配这些中文标点符号 。 ？ ！ ， 、 ； ： “ ” ‘ ' （ ） 《 》 〈 〉 【 】 『 』 「 」 ﹃ ﹄ 〔 〕 … — ～ ﹏ ￥
  # 外加白空格 和 /
  CHINESE_PUNCTUATION_MARKS_REGEX = %r{\u3002|\uff1f|\uff01|\uff0c|\u3001|\uff1b|\uff1a|\u201c|\u201d|\u2018|\u2019|\uff08|\uff09|\u300a|\u300b|\u3008|\u3009|\u3010|\u3011|\u300e|\u300f|\u300c|\u300d|\ufe43|\ufe44|\u3014|\u3015|\u2026|\u2014|\uff5e|\ufe4f|\uffe5|\s+|/}

  def parse
    url = 'https://www.jin10.com'

    logger.debug "visiting #{url}"

    session.visit url

    log = Log.create(type: 'jin10_latest_messages_parser')

    sleep 0.5 while (group_count = session.all('ul.classify-list li').count) < 2

    logger.debug "visiting #{url} done"

    sleep_seconds = 600

    proc do
      start_time = Time.now

      (group_count - 1).times do |i|
        logger.debug 'Clicking 更多'

        session.first(:xpath, './/span[contains(text(), "更多")]').click

        popup = nil

        retry_until_timeout(
          5,
          message:            'click "更多" again',
          keep_waiting_until: proc { popup = session.first('.classify-popup .scroll-view-container', minimum: 0) },
          when_timeout_do:    proc { session.first(:xpath, './/span[contains(text(), "更多")]').click(wait: 5) }
        )

        all_link = popup.all(:xpath, './/span[text()=" 全部 "]')[i]

        category = all_link.first(:xpath, '../preceding-sibling::dt').text

        # we can skip scraping category here.

        logger.debug "Clicking #{category}/全部"

        all_link.click

        # waiting popup disappear after click 全部
        sleep 0.5 while session.first('.classify-popup .scroll-view-container', minimum: 0)

        logger.debug "Clicking #{category}/全部 done"

        if @need_login
          logger.debug 'Need login when first time visit.'
          sleep 0.5 until session.has_css?('input#login_phone')

          session.within '#modal_login .modal-form' do
            session.fill_in id: 'login_phone', with: ENV['JIN10_USER']
            session.fill_in id: 'login_pwd', with: ENV['JIN10_PASS']
            session.click_button '登录'
          end
          logger.debug 'login done'
        end

        logger.debug 'waiting message is appear.'

        message = nil
        loop do
          sleep 2
          break if (message = session.first('#jin_flash_list .jin-flash-item-container', minimum: 0))
        end

        if @need_login
          # because message may be invalid.
          logger.debug 'will redo because login.'
          @need_login = false
          redo
        end

        # .right-content maybe not exists
        if (title = message.first('.right-content', minimum: 0))
          category = Jin10MessageCategory.find_or_create(name: category)
          text = title.text.gsub(/\s/, '')

          record = Jin10Message.find(
            title:        text,
            publish_date: Date.today
          )

          next if record.present?

          if text.start_with?('【')
            keyword = text[/【(.*)】.*/, 1]
            tag = Jin10MessageTag.find_or_create(name: keyword) if not keyword.match? CHINESE_PUNCTUATION_MARKS_REGEX and keyword.size < 8
          end

          new_record = {
            title:               text,
            keyword:             keyword || '',
            tag:                 tag,
            publish_date:        Date.today,
            publish_time_string: message.first('.item-time').text,
            category:            category,
            url:                 ''
          }

          new_record.update(important: true) if message.first('.jin-flash-item.flash')['class'].include?('is-important')

          Jin10Message.create(new_record)
        end
      rescue Capybara::ElementNotFound
        logger.error $!.full_message
        next
      end

      log.update(finished_at: Time.now)

      end_time = Time.now

      elapsed_seconds = (end_time - start_time).to_i

      # 确保 retry_timeout 可以 timeout
      logger.debug "Scraping done, wait for #{sleep_seconds - elapsed_seconds} seconds"

      sleep sleep_seconds
    end => message_parser_proc

    retry_until_timeout sleep_seconds, message: 'Refresh again', keep_waiting_if: message_parser_proc
  end
end
