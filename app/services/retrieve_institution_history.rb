class RetrieveInstitutionHistory < Actor
  input :days, default: 7, type: [Integer, String]
  input :sort_column, default: 'date', type: String
  input :sort_direction, default: 'desc', type: String
  input :institution_id, default: nil, type: Integer
  input :stock_id, default: nil, type: Integer
  input :stock_name, default: nil, type: String

  def call
    today = Date.today
    now = today.to_datetime

    sort = case sort_column.to_s
           when *InstitutionHistory.columns.map(&:name)
             :institution_histories[sort_column.to_sym]
           when 'stock_name'
             :stock[:name]
           else
             :stock[:name]
           end

    sort = sort.desc if sort_direction.to_s == 'desc'

    institution_histories = InstitutionHistory.eager_graph({stock: :exchange}, :institution)

    if stock_id.present?
      institution_histories = institution_histories.where(stock_id: stock_id)
    elsif stock_name.present?
      stock_id = Stock.find(name: stock_name)&.id
      institution_histories = institution_histories.where(stock_id: stock_id)
    elsif institution_id.present?
      institution_histories = institution_histories.where(institution_id: institution_id)
    else
      institution_histories = institution_histories.where(
        Sequel.or(
          date:       today - days.to_i..today,
          created_at: now...(today + 1).to_datetime
        )
      )
    end

    # 注意，这里加个 all 方法，下面 map 的时候，元素才是 institution
    # 没这个 all, 返回的直接是哈希。
    institution_histories = institution_histories.order(sort).all

    if institution_histories.empty?
      result.fail!(message: '没有最新的结果！')
    else
      result.institution_histories = institution_histories.map do |ins|
        stock = ins.stock

        _x = ins.market_value.divmod(10000)
        value = Helpers.number_with_comma(_x[0].to_f + _x[1] / 10000.to_f)

        if ins.quarterly_changes_percent.nil?
          value1 = 'N/A'
          value2 = 'N/A'
        elsif ins.quarterly_changes_percent == 0
          value1 = 'No Change'
          value2 = 'No Change'
        else
          value1 = "#{(ins.quarterly_changes_percent * 100).to_f}%"
          value2 = ins.quarterly_changes
        end

        if value1 == 'N/A'
          color = 'grey'
        elsif value1.to_i > 0
          color = 'green'
        else
          color = 'red'
        end

        {
          'ID' => ins.id,
          '股票' => stock.name,
          'stock_id' => stock.id,
          '日期' => ins.date.to_s,
          '机构名称' => ins.institution.display_name,
          'institution_id' => ins.institution.id,
          '机构持有数量' => Helpers.number_with_comma(ins.number_of_holding),
          '市场价值' => "#{value.to_f}万(#{ins.market_value_dollar_string})",
          '占股票百分比' => "#{(ins.percent_of_shares_for_stock * 100).to_f}%",
          '占机构百分比' => "#{(ins.percent_of_shares_for_institution * 100).to_f}%",
          '机构季度变动百分比' => value1,
          '机构季度变动数量' => Helpers.number_with_comma(value2),
          '机构平均成本' => ins.holding_cost.to_f,
          '创建时间' => ins.created_at.strftime('%m-%d %H:%M'),
          '颜色' => color
        }
      end
    end
  end
end
