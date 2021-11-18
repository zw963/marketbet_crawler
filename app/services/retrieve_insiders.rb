class RetrieveInsiders < Actor
  input :sort_column, default: 'last_trade_date', type: String
  input :sort_direction, default: 'desc', type: String
  input :page, default: '1', type: [Integer, String]
  input :per, default: '20', type: [Integer, String]
  input :stock_id, default: nil, type: Integer
  input :name, default: nil, type: String

  def call
    sort = case sort_column.to_s
           when *Insider.columns.map(&:name)
             :insiders[sort_column.to_sym]
           end

    if sort_direction.to_s == 'desc'
      sort = sort.desc
    else
      sort = sort.asc
    end

    insiders = Insider.dataset

    if stock_id.present?
      insiders = insiders.where(stock_id: stock_id)
    elsif name.present?
      insiders = insiders.where(name: name)
    end

    result.insiders = insiders.order(sort).paginate(page, per)

    result.fail!(message: "没有最新的结果！") if insiders.empty?
  end

  private

  def page
    result.page.to_i
  end

  def per
    result.per.to_i
  end
end
