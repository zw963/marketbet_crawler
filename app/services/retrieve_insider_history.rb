class RetrieveInsiderHistory
  include Interactor

  def call
    today = Date.today
    now = today.to_datetime
    days = context.days.to_i
    sort_column = context.sort_column || 'date'
    sort_direction = context.sort_direction
    stock_id = context.stock_id
    insider_id = context.insider_id
    stock_name = context.stock_name

    if sort_column.present?
      sort = case sort_column.to_s
             when *InsiderHistory.columns.map(&:name)
               :insider_histories[sort_column.to_sym]
             when 'insider_name'
               :insiders[:name]
             end
    end

    if sort.present? and sort_direction.to_s == 'desc'
      sort = sort.desc
    end

    # Two separate implementations are provided. eager should be used most of the time,
    # as it loads associated records using one query per association. However,
    # it does not allow you the ability to filter or order based on columns in associated tables.
    # eager_graph loads all records in a single query using JOINs, allowing you to filter
    # or order based on columns in associated tables. However, eager_graph is usually
    # slower than eager, especially if multiple one_to_many or many_to_many associations are joined.
    insider_histories = InsiderHistory.eager(:stock, :insider)

    if stock_id.present?
      insider_histories = insider_histories.where(stock_id: stock_id)
    elsif insider_id.present?
      insider_histories = insider_histories.where(insider_id: insider_id)
    elsif stock_name.present?
      stock_id = Stock.find(name: stock_name)&.id
      insider_histories = insider_histories.where(stock_id: stock_id)
    else
      insider_histories = insider_histories.where(
        Sequel.or(
          date: today-days..today,
          created_at: now...(today + 1).to_datetime
        )
      )
    end

    insider_histories = insider_histories.order(sort).all

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

    if insider_histories.empty?
      context.fail!(message: "没有最新的结果！")
    else
      context.insider_histories = insider_histories.map do |ih|
        title = ih.title
        stock = ih.stock

        unless mapping[title.downcase].to_s.downcase == title.downcase
          title = "#{title}(#{mapping[title.downcase]})"
        end

        {
          'ID' => ih.id,
          '股票' => stock.name,
          'stock_id' => ih.stock_id,
          'insider_id' => ih.insider_id,
          '日期' => ih.date.to_s,
          '名称' => ih.insider.name,
          '职位' => title,
          '股票变动数量' => ih.number_of_shares,
          '平均价格' => ih.average_price.to_f,
          '交易价格' => ih.share_total_price.to_f,
          '创建时间' => ih.created_at.strftime("%m-%d %H:%M")
        }
      end
    end
  end
end
