class RetrieveInvestingLatestNews
  include Interactor

  def call
    sort_column = context.sort_column || 'id'
    sort_direction = context.sort_direction || 'desc'
    page = context.page || 1
    per = context.per || 20

    if sort_column.present?
      sort = case sort_column.to_s
             when *InvestingLatestNews.columns.map(&:name)
               :investing_latest_news[sort_column.to_sym]
             end
    end

    if sort.present? and sort_direction.to_s == 'desc'
      sort = sort.desc
    end

    news = InvestingLatestNews.order(sort).paginate(page.to_i, per.to_i)

    if news.empty?
      context.fail!(message: "没有最新的结果！")
    else
      context.news = news
    end
  end
end
