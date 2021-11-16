class RetrieveInsiders
  include Interactor

  def call
    sort_column = context.sort_column || 'last_trade_date'
    sort_direction = context.sort_direction || 'desc'
    page = context.page || 1
    per = context.per || 20
    stock_id = context.stock_id
    name = context.name

    if sort_column.present?
      sort = case sort_column.to_s
             when *Insider.columns.map(&:name)
               :insiders[sort_column.to_sym]
             end
    end

    if sort.present?
      if sort_direction.to_s == 'desc'
        sort = sort.desc
      else
        sort = sort.asc
      end
    end

    insiders = Insider.dataset

    if stock_id.present?
      insiders = insiders.where(stock_id: stock_id)
    elsif name.present?
      insiders = insiders.where(name: name)
    end

    context.insiders = insiders.order(sort).paginate(page.to_i, per.to_i)

    context.fail!(message: "没有最新的结果！") if insiders.empty?
  end
end
