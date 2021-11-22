class RetrieveInstitutions < Actor
  input :days, default: 7, type: [Integer, String]
  input :sort_column, default: 'date', type: String
  input :sort_direction, default: 'desc', type: String
  input :firm_id, default: nil, type: Integer
  input :stock_id, default: nil, type: Integer
  input :stock_name, default: nil, type: String

  def call
    today = Date.today
    now = today.to_datetime

    sort = case sort_column.to_s
           when *Institution.columns.map(&:name)
             :institutions[sort_column.to_sym]
           when 'stock_name'
             :stock[:name]
           end

    if sort_direction.to_s == 'desc'
      sort = sort.desc
    end

    institutions = Institution.eager_graph({stock: :exchange}, :firm)

    if stock_id.present?
      institutions = institutions.where(stock_id: stock_id)
    elsif stock_name.present?
      stock_id = Stock.find(name: stock_name)&.id
      institutions = institutions.where(stock_id: stock_id)
    elsif firm_id.present?
      institutions = institutions.where(firm_id: firm_id)
    else
      institutions = institutions.where(
        Sequel.or(
          date: today-days..today,
          created_at: now...(today + 1).to_datetime
        )
      )
    end

    # 注意，这里加个 all 方法，下面 map 的时候，元素才是 institution
    # 没这个 all, 返回的直接是哈希。
    institutions = institutions.order(sort).all

    if institutions.empty?
      result.fail!(message: "没有最新的结果！")
    else
      result.institutions = institutions.map do |ins|
        stock = ins.stock

        _x = ins.market_value.divmod(10000)
        value = _x[0].to_f + _x[1]/10000.to_f

        if ins.quarterly_changes_percent.nil?
          value1 = 'N/A'
          value2 = 'N/A'
        elsif ins.quarterly_changes_percent == 0
          value1 = 'No Change'
          value2 = 'No Change'
        else
          value1 = (ins.quarterly_changes_percent*100).to_f.to_s + "%"
          value2 = ins.quarterly_changes
        end

        firm_name = ins.firm.display_name.presence || ins.firm.name

        {
          'ID' => ins.id,
          '股票' => stock.name,
          'stock_id' => stock.id,
          '日期' => ins.date.to_s,
          '机构名称' => firm_name,
          'firm_id' => ins.firm.id,
          '机构持有数量' => ins.number_of_holding,
          '市场价值' => "#{value.to_i}万(#{ins.market_value_dollar_string})",
          '占股票百分比' => (ins.percent_of_shares_for_stock*100).to_f.to_s + "%",
          '占机构百分比' => (ins.percent_of_shares_for_institution*100).to_f.to_s + "%",
          '机构季度变动百分比' => value1,
          '机构季度变动数量' => value2,
          '机构平均成本' => ins.holding_cost.to_f,
          '创建时间' => ins.created_at.strftime("%m-%d %H:%M")
        }
      end
    end
  end

  private

  def days
    result.days.to_i
  end
end
