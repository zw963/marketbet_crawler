class RetrieveLatestInsider
  include Interactor

  def call
    today = Date.today
    now = today.to_datetime
    days = context.days.to_i
    sort_column = context.sort_column || :date
    sort_direction = context.sort_direction

    if sort_column.present?
      sort = case sort_column.to_s
             when Insider.columns.map(&:to_s)
               :insiders[sort_column.to_sym]
             end
    end

    if sort.present? and sort_direction.to_s == 'desc'
      sort = sort.desc
    end

    insiders = Insider.eager(stock: :exchange).where(
      Sequel.or(
        date: today-days..today,
        created_at: now...(today + 1).to_datetime
      )
    ).order(sort).all

    mapping = {
      'major shareholder' => "大股东",
      "insider" => "内部人士",
      "ceo" => "CEO",
      "director" => "董事",
      "cto" => "CTO",
      "cfo" => "CFO",
      "coo" => "首席运营官",
      "general counsel" => "顾问",
      "svp" => "高级副总裁",
      "vp" => "副总裁",
      "evp" => "执行副总裁",
      "cao" => "首席行政官",
      "vice chairman" => "副董事長",
      "chairman" => "董事長",
      "cmo" => "首席市场官",
      'president' => '总裁'
    }

    if insiders.empty?
      context.fail!(message: "没有最新的结果！")
    else
      context.insiders = insiders.map do |ins|
        title = ins.title
        stock = ins.stock

        unless mapping[title.downcase].to_s.downcase == title.downcase
          title = "#{title}(#{mapping[title.downcase]})"
        end

        {
          'ID' => ins.id,
          '股票' => "#{stock.exchange.name}/#{stock.name}",
          '日期' => ins.date.to_s,
          '名称' => ins.name,
          '职位' => title,
          '股票变动数量' => ins.number_of_shares,
          '平均价格' => ins.average_price.to_f,
          '交易价格' => ins.share_total_price.to_f,
          '创建时间' => ins.created_at.strftime("%m-%d %H:%M")
        }
      end
    end
  end
end
