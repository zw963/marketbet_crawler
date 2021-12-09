class Jin10MessagesParser < ParserBase
  # 匹配这些中文标点符号 。 ？ ！ ， 、 ； ： “ ” ‘ ' （ ） 《 》 〈 〉 【 】 『 』 「 」 ﹃ ﹄ 〔 〕 … — ～ ﹏ ￥
  # 外加白空格 和 /
  CHINESE_PUNCTUATION_MARKS_REGEX = %r{\u3002|\uff1f|\uff01|\uff0c|\u3001|\uff1b|\uff1a|\u201c|\u201d|\u2018|\u2019|\uff08|\uff09|\u300a|\u300b|\u3008|\u3009|\u3010|\u3011|\u300e|\u300f|\u300c|\u300d|\ufe43|\ufe44|\u3014|\u3015|\u2026|\u2014|\uff5e|\ufe4f|\uffe5|\s+|/}

  def parse
    session = Capybara::Session.new(:cuprite)
    session.visit('https://ucenter.jin10.com')

    sleep 5 until session.has_css?('#J_loginPhone', wait: 10)

    session.within '#J_loginForm' do
      session.fill_in id: 'J_loginPhone', with: ENV['JIN10_USER']
      session.fill_in id: 'J_loginPassword', with: ENV['JIN10_PASS']
      session.click_button '登录'
    end

    sleep 0.5 until session.has_css?('div.ucenter-menu span.ucenter-menu_title')

    url = 'https://www.jin10.com'
    session.visit url
    logger.info "goto #{url}"

    log = Log.create(type: 'jin10_latest_messages_parser')

    while (group_count = session.all('ul.classify-list li', wait: 10).count) < 2
      sleep 5
    end

    sleep_seconds = 400

    message_parser_proc = proc do
      start_time = Time.now
      (group_count-1).times do |i|
        logger.info 'Clicking 更多'

        # Ferrum::TimeoutError
        session.first(:xpath, './/span[contains(text(), "更多")]').click

        until (popup = session.first('.classify-popup .scroll-view-container', minimum: 0))
          sleep 0.5
        end

        click_node = popup.all(:xpath, './/span[text()=" 全部 "]')[i]
        category_ele = click_node.first(:xpath, '../preceding-sibling::dt')
        category = category_ele.text
        logger.info "Clicking #{category}/全部"

        # Ferrum::TimeoutError
        click_node.click

        until (message = session.first('#jin_flash_list .jin-flash-item-container', minimum: 0))
          sleep 0.5
        end

        # Capybara::Cuprite::ObsoleteNode
        if (title = message.first('.right-content', minimum: 0))
          category = Jin10MessageCategory.find_or_create(name: category)
          text = title.text.gsub(/\s/, '')

          record = Jin10Message.find(
            # Capybara::Cuprite::ObsoleteNode
            title: text,
            publish_date: Date.today
          )

          next if record.present?

          if text.start_with?('【')
            keyword = text[/【(.*)】.*/, 1]
            if not keyword.match? CHINESE_PUNCTUATION_MARKS_REGEX and keyword.size < 8
              tag = Jin10MessageTag.find_or_create(name: keyword)
            end
          end

          new_record = {
            title: text,
            keyword: keyword || '',
            tag: tag,
            publish_date: Date.today,
            publish_time_string: message.first('.item-time').text,
            category: category,
            url: ''
          }

          if message.first('.jin-flash-item.flash')['class'].include?('is-important')
            new_record.update(important: true)
          end

          Jin10Message.create(new_record)
        end
      rescue Capybara::ElementNotFound
        logger.error $!.full_message
        next
      end

      # # 这里还要检测登录的问题
      # # form.modal-form input#login_phone, form.modal-form input#login_pwd
      # # form.modal-form button.user-submit

      log.update(finished_at: Time.now)

      end_time = Time.now

      elapsed_seconds = (end_time - start_time).to_i

      # 确保 retry_timeout 可以 timeout
      logger.info "Done, wait for #{sleep_seconds - elapsed_seconds} seconds"
      sleep sleep_seconds
    end

    retry_timeout sleep_seconds, message: 'Refresh again', waiting_for_if: message_parser_proc
  end

  def wait_for_valid(&block)
    loop do
      ele=block.call
      if (ele.moving? rescue nil)
        break ele
      end

      sleep 0.5
    end
  end
end
