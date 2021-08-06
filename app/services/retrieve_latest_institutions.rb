class RetrieveLatestInstitutions
  include Interactor

  def call
    today = Date.today
    now = today.to_datetime
    days = context.days

    institutions = Institution.where(
      Sequel.or(
        date: today-days..today,
        created_at: now...(today + 1).to_datetime
      )
    ).order(:stock_id)

    if institutions.empty?
      context.fail!(message: "没有最新的结果！")
    else
      context.institutions = institutions.map do |ins|
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

        {
          'ID' => ins.id,
          '股票' => "#{stock.exchange.name}/#{stock.name}",
          '日期' => ins.date.to_s,
          '机构名称' => ins.name,
          '机构持有数量' => ins.number_of_holding,
          '市场价值' => "#{value}万(#{ins.market_value_dollar_string})",
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
end
