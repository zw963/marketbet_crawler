class RetrieveInvestingLatestNews
  include Interactor

  def call
    sort_column = context.sort_column || 'id'
    sort_direction = context.sort_direction || 'desc'
    page = context.page || 1
    per = context.per || 20
    q = context.q

    if sort_column.present?
      sort = case sort_column.to_s
             when *InvestingLatestNews.columns.map(&:name)
               :investing_latest_news[sort_column.to_sym]
             end
    end

    if sort.present? and sort_direction.to_s == 'desc'
      sort = sort.desc
    end

    news = InvestingLatestNews.dataset

    if q.present?
      news = news.where(Sequel.lit('textsearchable_index_col @@ to_tsquery(?)', q))
    end

    context.news = news.order(sort).paginate(page.to_i, per.to_i)
    context.fail!(message: "没有结果！") if news.empty?
  end
end
