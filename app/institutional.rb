class Institutional
  include Singleton
  attr_accessor :symbols, :instance, :page

  def initialize
    # self.instance = Ferrum::Browser.new(headless: false, window_size: [1800, 1080], browser_options: {"proxy-server": "socks5://127.0.0.1:22336"})
    self.instance = Ferrum::Browser.new(headless: true, browser_path: "/usr/bin/google-chrome-stable", process_timeout: 60, browser_options: { 'no-sandbox': t })
  end

    def parse
    raise 'symbols must be exists' if symbols.nil?

    symbols.map do |symbol|
      Thread.new(instance) do |browser|
        context = browser.contexts.create
        page = context.create_page
        puts "https://www.marketbeat.com/stocks/#{symbol.upcase}/institutional-ownership"
        page.go_to("https://www.marketbeat.com/stocks/#{symbol.upcase}/institutional-ownership")

        tries = 0
        begin
          tries += 1
          page.network.wait_for_idle(timeout: 30)
        rescue Ferrum::TimeoutError
          puts 'Retrying'
          if (tries < 4)
            sleep(2**tries)
            retry
          end
        end

        # if (ele = browser.at_css('#optinform-modal'))
        #   ele.evaluate("closeIframeModal();return false;")
        # end

        if (table_ele = page.at_css('.scroll-table-wrapper-wrapper'))
          tables = table_ele.inner_text.split("\n").reject(&:empty?).map {|x| x.split("\t") }
          # puts Terminal::Table.new :rows => tables
          print_table(tables)
        end

        context.dispose
      end
    end.each(&:join)

    instance.quit
  end

  def print_table(table_ary)
    heading = [
      "日期",
      "机构名称",
      "持有数量",
      "市场价值",
      "占股票百分比",
      "占机构百分比",
      "机构季度变动百分比",
      "机构季度变动数量",
    ]

    matched_date = [Date.today, Date.today-1].map {|x| x.to_time.strftime('%-m/%d/%Y') }

    latest_data = table_ary[1..-1].select {|x| matched_date.include? x[0] }

    data = latest_data.map do |e|
      e[3] =~ /\$([\d.,]+)(.?)/
      case
      when $2 == "K"
        value = $1.to_f * 1000
      when $2 == "M"
        value = $1.to_f * 1000000
      when $2 == "B"
        value = $1.to_f * 1000000000
      else
        value = $1.to_f
      end

      x = value.divmod(10000)
      value = x[0].to_f + x[1]/10000.to_f

      current_share_total = e[2].tr(',', '').to_i
      quarterly_changed_share_percent = e[5].chop.to_f/100
      shared_changed = current_share_total - ((current_share_total)/(1+quarterly_changed_share_percent)).to_i

      [
        e[0],
        e[1],
        e[2],
        value.to_s + "万(#{e[3]})",
        e[6],
        e[4],
        e[5],
        shared_changed,
      ]
    end

    table = Terminal::Table.new do |t|
      t.style = { :border => :unicode_round }
      t.headings = heading
      data.each {|e| t.add_row(e) }
      t.style = {:all_separators => true}
    end

    puts table
  end
end
