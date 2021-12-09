class App < Roda
  path :link do |title, current_column|
    params = request.params.dup
    sort_column = params.delete('sort_column')
    sort_direction = params.delete('sort_direction')
    direction = (current_column == sort_column && sort_direction == 'desc') ? 'asc' : 'desc'
    query_string = URI.encode_www_form(sort_column: current_column, sort_direction: direction, **params)
    href = request.path
    href = "#{href}?#{query_string}" if query_string.present?
    "<a href=\"#{href}\">#{title}</a>"
  end
end
