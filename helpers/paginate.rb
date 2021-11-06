class App < Roda
  path :page do |page, title, page_size=10|
    params = request.params.dup
    query_string = URI.encode_www_form(params.merge({'page' => page, 'per' => page_size}))
    href = request.path
    href = "#{href}?#{query_string}" if query_string.present?
    anchor_class = "waves-effect waves-light btn-small"
    anchor_class = "#{anchor_class} disabled" if page.nil?
    "<a class=\"#{anchor_class}\" href=\"#{href}\">#{title}</a>"
  end

  def paginate(records)
    next_page = records.next_page
    prev_page = records.prev_page
    "#{page_path(prev_page, '上一页')}\
第#{records.current_page}页，总共 #{records.page_count} 页 \
#{page_path(next_page, '下一页')}"
  end
end
