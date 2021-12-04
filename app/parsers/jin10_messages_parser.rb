class Jin10MessagesParser < ParserBase
  def parse
    instance.goto 'https://ucenter.jin10.com'

    while not (
      (form=instance.at_css('#J_loginForm')) &&
        (login=form.at_css('#J_loginPhone')) &&
        login.focusable?
    )
      sleep 1
    end

    login.focus.type(ENV['JIN10_USER'])
    form.at_css('#J_loginPassword').focus.type(ENV['JIN10_PASS'])
    form.at_css('button[type="submit"]').click

    unless instance.at_css('#J_logout_wrap')
      sleep 3
    end

    message_parser_proc = Proc.new do
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

      old_id, new_id = nil, nil
      old_category, new_category = nil, nil
      should_redo, redo_done, redo_times = false, false, 1

      (group_count-1).times do |i|
        more_link = wait_for_valid { instance.at_xpath('.//span[contains(text(), "更多")]') }
        more_link.click

        retry_timeout(
          5,
          waiting_for_if: proc { not instance.at_css('.classify-popup .scroll-view-container') },
          when_timeout_do: proc { more_link.click },
          message: 'Try click "更多" scroll-view again.'
        )

        while not (popup = instance.at_css('.classify-popup .scroll-view-container'))
          sleep 1
        end

        if should_redo
          popup.at_css(".classify-panel-bd-item dl dt span").click
          redo_times.times do
            logger.info 'page down!'
            instance.keyboard.type(:pagedown)
            sleep 1
          end
          redo_done = true
        end

        click_node = popup.xpath('.//span[contains(text(), "全部")]')[i]
        new_category = click_node.at_xpath('../preceding-sibling::dt').text
        click_node.click
        logger.info "Click category #{new_category}, previous category: #{old_category}"

        timeout 5 do
          instance.at_css('.classify-popup .scroll-view-container')
        end

        unless (message = instance.at_css('#jin_flash_list .jin-flash-item-container'))
          sleep 1
        end

        new_id = message.attribute(:id)
        logger.info "new_id #{new_id}, old_id: #{old_id}"
        sleep 1

        if old_category != new_category && new_id == old_id
          # 如果不同分类，但是元素没有刷新，表示市场讯息没有如期刷新，即 click 没有生效.
          should_redo = true
          redo_times += 1 if redo_done
          logger.info 'Redoing because link not clickable'
          redo
        end

        old_id = message.attribute(:id)
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
      rescue Ferrum::NodeNotFoundError
        logger.error $!.backtrace.join("\n")
        next
      end

      log.update(finished_at: Time.now)

      # 确保 retry_timeout 可以 timeout
      sleep 600
    end

    retry_timeout 600, message: 'Try https://www.jin10.com again', waiting_for_if: message_parser_proc
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
