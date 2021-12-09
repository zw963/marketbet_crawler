class RetrieveInvestingLatestNews < Actor
  input :sort_column, default: 'id', type: String
  input :sort_direction, default: 'desc', type: String
  input :page, default: 1, type: [Integer, String]
  input :per, default: 30, type: [Integer, String]
  input :q, default: nil, type: String

  def call
    sort = case sort_column.to_s
           when *InvestingLatestNews.columns.map(&:name)
             :investing_latest_news[sort_column.to_sym]
           end

    if sort_direction.to_s == 'desc'
      sort = sort.desc
    end

    news = InvestingLatestNews.dataset

    if q.present?
      news = news.where(Sequel.lit('textsearchable_index_col @@ to_tsquery(?)', q))
    end

    result.news = news.order(sort).paginate(page.to_i, per.to_i)
    result.fail!(message: "没有结果！") if news.empty?
  end
end
