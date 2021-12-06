class Jin10SkipCategoryException < RuntimeError
end

class Jin10MessagesParserOld < ParserBase
  def parse
    instance.goto 'https://ucenter.jin10.com'

    while not (
      (form=instance.at_css('#J_loginForm')) &&
        (login=form.at_css('#J_loginPhone')) &&
        login.focusable?
    )
      sleep 0.5
    end

    login.focus.type(ENV['JIN10_USER'])
    form.at_css('#J_loginPassword').focus.type(ENV['JIN10_PASS'])
    instance.network.wait_for_idle
    form.at_css('button[type="submit"]').click

    # 好大的坑啊，这里好多应该用 until 的地方，用的是 unless.
    # 先不改了，备忘.
    unless instance.at_css('#J_logout_wrap .ucenter-menu_title')
      sleep 3
    end

    sleep_time = 420

    message_parser_proc = proc do
      url = 'https://www.jin10.com'
      instance.goto url
      logger.info "goto #{url}"

      log = Log.create(type: 'jin10_latest_messages_parser')

      while (group_count = instance.css('ul.classify-list li').count) < 2
        sleep 0.5
      end

      instance.execute("if ('scrollRestoration' in history) {
      history.scrollRestoration = 'manual';
      }")

      # 这里还要检测登录的问题
      # form.modal-form input#login_phone, form.modal-form input#login_pwd
      # form.modal-form button.user-submit

      old_id, old_category, new_category = nil, nil, nil

      (group_count-1).times do |i|
        message = nil

        (0...5).cycle do |e|
          # 先置顶
          # instance.execute("window.scrollTo({ top: 0, behavior: 'smooth' })")

          # instance.wait_for_stop_moving

          if not instance.at_css('.classify-popup .scroll-view-container')
            more_link = wait_for_valid { instance.at_xpath('.//span[contains(text(), "更多")]') }
            instance.network.wait_for_idle
            more_link.click
            instance.network.wait_for_idle

            retry_timeout(
              5,
              waiting_for_if: proc { not instance.at_css('.classify-popup .scroll-view-container') },
              # when_timeout_do: proc { instance.keyboard.type(:pageup); more_link.click },
              message: 'Try clicking "更多" scroll-view again.'
            )
          end

          unless (popup = instance.at_css('.classify-popup .scroll-view-container'))
            sleep 0.5
          end

          click_node = popup.xpath('.//span[text()=" 全部 "]')[i]
          instance.network.wait_for_idle
          pry! if click_node.nil?
          category_ele = click_node.at_xpath('../preceding-sibling::dt')
          pry! if category_ele.nil?
          new_category = category_ele.text

          raise Jin10SkipCategoryException if ['贵金属', '石油', '外汇', '期货', '数字货币', '科技', '地缘局势'].include? new_category

          popup.at_css(".classify-panel-bd-item dl dt span").click

          logger.info "Will move to #{e}'th page" if e > 0

          e.times do |i|
            # 表示找不到下一个 全部 link, 尝试往下翻页再尝试点击 link
            sleep 0.8
            # logger.info 'keyboard move pagedown!'
            instance.keyboard.type(:pagedown)
          end

          # click_node.wait_for_stop_moving
          instance.network.wait_for_idle

          logger.info "Will clicking #{new_category}/全部"

          sleep 2

          # 一个好大的坑，点这个按钮时，会出现有时候底部栏的链接覆盖了 view, 坑啊
          click_node.click
          sleep 1
          logger.info "Clicking category #{new_category}/全部"

          if instance.at_css('.classify-popup .scroll-view-container')
            sleep 0.5
          end

          unless (message = instance.at_css('#jin_flash_list .jin-flash-item-container'))
            sleep 0.5
          end

          new_id = instance.at_css('li.classify-item.active').attribute('data-id')
          # 如果不同分类，但是元素没有刷新，表示市场讯息没有如期刷新，即 click 没有生效.
          if old_category != new_category && new_id == old_id
            # puts "old_cateory: #{old_category}, new_category: #{new_category}"
            # puts "old_id: #{old_id}, new_id: #{new_id}"
            # do nothing, continuing loop.
          else
            break
          end
        end

        old_id = instance.at_css('li.classify-item.active').attribute('data-id')
        old_category = new_category

        if (title = message.at_css('.right-content'))
          category = Jin10MessageCategory.find_or_create(name: old_category)

          record = Jin10Message.find(
            title: title.text,
            publish_date: Date.today
          )

          next if record.present?

          new_record = {
            title: title.text,
            publish_date: Date.today,
            publish_time_string: message.at_css('.item-time').text,
            category: category,
            url: ''
          }

          if message.at_css('.jin-flash-item.flash').attribute('class').include?('is-important')
            new_record.update(important: true)
          end

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
