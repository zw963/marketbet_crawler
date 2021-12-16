class App < Roda
  path :page do |page, title, page_size|
    params = request.params.dup
    query_string = URI.encode_www_form(params.merge({'page' => page, 'per' => page_size}))
    href = request.path
    href = "#{href}?#{query_string}" if query_string.present?
    anchor_class = "waves-effect waves-light btn-small"
    anchor_class = "#{anchor_class} disabled" if page.nil?
    "<a class=\"#{anchor_class}\" href=\"#{href}\">#{title}</a>"
  end

  def paginate(records)
    page_size = records.page_size
    page_count = records.page_count

    "#{page_path(1, '首页', page_size)}#{page_path(records.prev_page, '上一页', page_size)}\
第#{records.current_page}页，返回 #{records.current_page_record_count}/#{records.pagination_record_count} 条，总共 #{page_count} 页 \
#{page_path(records.next_page, '下一页', page_size)}#{page_path(page_count, '末页', page_size)}"
  end
end
