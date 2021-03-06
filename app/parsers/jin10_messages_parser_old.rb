class Jin10SkipCategoryException < RuntimeError
end

class Jin10MessagesParserOld < ParserBase
  def parse
    # url = 'https://ucenter.jin10.com'
    # logger.info "Visiting #{url}"
    # browser.goto url

    # until (form=browser.at_css('#J_loginForm')) &&
    #     (login=form.at_css('#J_loginPhone')) &&
    #     login.focusable?

    #   sleep 0.5
    # end

    # logger.info "Visiting #{url} done"

    # login.focus.type(ENV['JIN10_USER'])
    # form.at_css('#J_loginPassword').focus.type(ENV['JIN10_PASS'])
    # browser.network.wait_for_idle
    # logger.info 'try clicking'
    # form.at_css('button[type="submit"]').click
    # logger.info 'click done'

    # logger.info 'waiting enter user center'
    # until browser.at_css('div.ucenter-menu span.ucenter-menu_title')
    #   sleep 3
    #   puts 'sleep for div.ucenter-menu span.ucenter-menu_title'
    # end
    # logger.info 'login done'

    sleep_time = 420

    message_parser_proc = proc do
      url = 'https://www.jin10.com'
      logger.info "visiting #{url}"
      browser.goto url

      log = Log.create(type: 'jin10_latest_messages_parser')

      while (group_count = browser.css('ul.classify-list li').count) < 2
        sleep 2
        puts 'waiting for ul.classify-list li size must > 2'
      end
      logger.info "visit #{url} done"

      browser.execute("if ('scrollRestoration' in history) {
      history.scrollRestoration = 'manual';
      }")

      # 这里还要检测登录的问题
      # form.modal-form input#login_phone, form.modal-form input#login_pwd
      # form.modal-form button.user-submit

      old_id, old_category, new_category = nil, nil, nil
      need_login = true
      # skipped_category = ['贵金属', '石油', '外汇', '期货', '数字货币', '科技', '地缘局势'].freeze
      skipped_category = [].freeze

      (group_count - 1).times do |i|
        message = nil

        (0...5).cycle do |e|
          # 先置顶
          # browser.execute("window.scrollTo({ top: 0, behavior: 'smooth' })")

          # browser.wait_for_stop_moving

          if not browser.at_css('.classify-popup .scroll-view-container')
            more_link = wait_for_valid { browser.at_xpath('.//span[contains(text(), "更多")]') }
            # browser.network.wait_for_idle
            more_link.click
            # browser.network.wait_for_idle
          end

          # retry_timeout(
          #   5,
          #   waiting_for_if: proc { not browser.at_css('.classify-popup .scroll-view-container') },
          #   # when_timeout_do: proc { browser.keyboard.type(:pageup); more_link.click },
          #   message: 'Try clicking "更多" scroll-view again.'
          # )

          until (popup = browser.at_css('.classify-popup .scroll-view-container'))
            sleep 2
            puts 'waiting for popup appear'
          end

          click_node = popup.xpath('.//span[text()=" 全部 "]')[i]
          # browser.network.wait_for_idle
          category_ele = click_node.at_xpath('../preceding-sibling::dt')
          new_category = category_ele.text

          raise Jin10SkipCategoryException if skipped_category.include? new_category

          popup.at_css('.classify-panel-bd-item dl dt span').click

          logger.info "Will move to #{e}'th page" if e > 0

          e.times do |_i|
            # 表示找不到下一个 全部 link, 尝试往下翻页再尝试点击 link
            sleep 0.8
            logger.info 'keyboard move pagedown!'
            browser.keyboard.type(:pagedown)
          end

          # click_node.wait_for_stop_moving
          # browser.network.wait_for_idle #

          logger.info "Will clicking #{new_category}/全部"

          # 一个好大的坑，点这个按钮时，会出现有时候底部栏的链接覆盖了 view, 坑啊
          click_node.click

          logger.info "Clicking category #{new_category}/全部"

          while browser.at_css('.classify-popup .scroll-view-container')
            sleep 2
            puts 'waiting for popup disappear'
          end

          if need_login
            until (login_phone = browser.at_css('input#login_phone')) &&
                login_phone.focusable?
            end
            login_phone.focus.type(ENV['JIN10_USER'])
            browser.at_css('input#login_pwd').focus.type(ENV['JIN10_PASS'])

            login_phone.at_xpath('../../following-sibling::button[@data-type="login"]').click
          end

          until (active_tab = browser.at_css('li.classify-item.active'))
            sleep 2
            puts 'waiting for active tab appear'
          end

          if need_login
            need_login = false
            puts 'will redo'
            redo
          end

          new_id = active_tab.attribute('data-id')
          # 如果不同分类，但是元素没有刷新，表示市场讯息没有如期刷新，即 click 没有生效.
          if old_category != new_category && new_id == old_id
            # puts "old_cateory: #{old_category}, new_category: #{new_category}"
            # puts "old_id: #{old_id}, new_id: #{new_id}"
            # do nothing, continuing loop.
          else
            break
          end
        end

        until (message = browser.at_css('#jin_flash_list .jin-flash-item-container'))
          sleep 2
          puts 'waiting for flash message appear'
        end

        old_id = browser.at_css('li.classify-item.active').attribute('data-id')
        old_category = new_category

        if (title = message.at_css('.right-content'))
          category = Jin10MessageCategory.find_or_create(name: old_category)

          record = Jin10Message.find(
            title:        title.text,
            publish_date: Date.today
          )

          next if record.present?

          new_record = {
            title:               title.text,
            publish_date:        Date.today,
            publish_time_string: message.at_css('.item-time').text,
            category:            category,
            url:                 ''
          }

          new_record.update(important: true) if message.at_css('.jin-flash-item.flash').attribute('class').include?('is-important')

          Jin10Message.create(new_record)
        end
      rescue Jin10SkipCategoryException
        next
        # rescue Ferrum::NodeNotFoundError
        #   logger.error $!.backtrace.join("\n")
        # next
      end

      log.update(finished_at: Time.now)

      # 确保 retry_timeout 可以 timeout
      logger.info "Done, sleep for #{sleep_time} seconds"
      sleep sleep_time
    end

    # begin
    message_parser_proc.call
    # rescue
    #   pry!
    # end
    # retry_timeout sleep_time, message: 'Try https://www.jin10.com again', waiting_for_if: message_parser_proc
  end
end
