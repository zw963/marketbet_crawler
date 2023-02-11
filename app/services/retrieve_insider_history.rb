class RetrieveInsiderHistory < Actor
  input :days, default: 15, type: [Integer, String]
  input :sort_column, default: 'date', type: String
  input :sort_direction, default: 'desc', type: String
  input :stock_name, default: nil, type: String
  input :stock_id, default: nil, type: Integer
  input :insider_id, default: nil, type: Integer

  def call
    today = Date.today
    now = today.to_datetime

    sort = case sort_column.to_s
           when *InsiderHistory.columns.map(&:name)
             :insider_histories[sort_column.to_sym]
           when 'insider_name'
             :insiders[:name]
           end

    sort = sort.desc if sort_direction.to_s == 'desc'

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
          date:       today - days.to_i..today,
          created_at: now...(today + 1).to_datetime
        )
      )
    end

    insider_histories = insider_histories.order(sort).all

    mapping = {
      'major shareholder' => '大股东',
      'insider' => '内部人士',
      'ceo' => 'CEO',
      'director' => '董事',
      'cto' => 'CTO',
      'cfo' => 'CFO',
      'coo' => '首席运营官',
      'general counsel' => '顾问',
      'svp' => '高级副总裁',
      'vp' => '副总裁',
      'evp' => '执行副总裁',
      'cao' => '首席行政官',
      'vice chairman' => '副董事長',
      'chairman' => '董事長',
      'cmo' => '首席市场官',
      'president' => '总裁'
    }

    result.fail!(message: '没有最新的结果！') if insider_histories.empty?

    result.insider_histories = insider_histories.map do |ih|
      title = ih.title
      stock = ih.stock

      title = "#{title}(#{mapping[title.downcase]})" unless mapping[title.downcase].to_s.casecmp(title).zero?

      {
        'ID' => ih.id,
        '股票' => stock.name,
        'stock_id' => ih.stock_id,
        'insider_id' => ih.insider_id,
        '日期' => ih.date.to_s,
        '名称' => ih.insider.name,
        '职位' => title,
        '股票变动数量' => Helpers.number_with_comma(ih.number_of_shares),
        '平均价格' => Helpers.number_with_comma(ih.average_price.to_f),
        '交易价格' => Helpers.number_with_comma(ih.share_total_price.to_f),
        '创建时间' => ih.created_at.strftime('%m-%d %H:%M'),
        '颜色' => ih.number_of_shares.to_i > 0 ? 'green' : 'red'
      }
    end
  end
end
