class App < Roda
  def highlight_keyword(keyword, str)
    str.gsub!(/#{keyword}/, '<span class=" blue lighten-4">\&</span>') if keyword.present?
    str
  end
end
