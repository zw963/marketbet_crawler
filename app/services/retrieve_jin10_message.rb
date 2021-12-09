class RetrieveJin10Message < Actor
  input :sort_column, default: 'id', type: String
  input :sort_direction, default: 'desc', type: String
  input :page, default: 1, type: [Integer, String]
  input :per, default: 100, type: [Integer, String]
  input :q, default: nil, type: String
  input :days, default: 1, type: [Integer, String]
  input :category_id, default:nil, type: [String, Integer]

  def call
    sort = case sort_column.to_s
           when *Jin10Message.columns.map(&:name)
             :jin10_messages[sort_column.to_sym]
           end

    if sort_direction.to_s == 'desc'
      sort = sort.desc
    end

    messages = Jin10Message.dataset

    if days.to_i == 1
      messages = Jin10Message.where(publish_date: Sequel.lit('current_date'))
    end

    if category_id.present?
      category = Jin10MessageCategory[category_id]
      messages = messages.where(category: category)
    end

    if q.present?
      messages = messages.where(Sequel.lit('textsearchable_index_col @@ to_tsquery(?)', q))
    end

    result.messages = messages.order(sort).paginate(page.to_i, per.to_i)
    result.fail!(message: "没有结果！") if messages.empty?
  end
end
