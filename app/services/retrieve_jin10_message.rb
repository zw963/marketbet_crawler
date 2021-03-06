class RetrieveJin10Message < Actor
  input :sort_column, default: 'id', type: String
  input :sort_direction, default: 'desc', type: String
  input :page, default: 1, type: [Integer, String]
  input :per, default: 100, type: [Integer, String]
  input :q, default: nil, type: String
  input :days, default: 2, type: [Integer, String]
  input :tag_ids, default: [], type: [Array]

  def call
    sort = case sort_column.to_s
           when *Jin10Message.columns.map(&:name)
             :jin10_messages[sort_column.to_sym]
           end

    sort = sort.desc if sort_direction.to_s == 'desc'

    messages = Jin10Message.dataset

    case days.to_i
    when 2
      # 默认只显示当天和前一天的
      messages = Jin10Message.where(publish_date: [Sequel.lit('current_date'), Sequel.lit('current_date - 1')])
    when -1
      if q.blank? and tag_ids.include? '-1'
        messages = Jin10Message.dataset.nullify
        fail_message = '搜索全部结果，必须指定标签或搜索关键字！'
      else
        messages = Jin10Message.dataset
      end
    else
      messages = Jin10Message.where {|r| r.publish_date > Sequel.lit('current_date - interval ?', "#{days} days")}
    end

    messages = messages.where(jin10_message_tag_id: tag_ids) if not (tag_ids.include? '-1' or tag_ids.blank?)

    messages = messages.where(Sequel.lit('textsearchable_index_col @@ to_tsquery(?)', q)) if q.present?

    result.messages = messages.order(sort).paginate(page.to_i, per.to_i)
    fail_message ||= '没有结果！' if messages.empty?

    result.fail!(message: fail_message) if fail_message.present?
  end
end
