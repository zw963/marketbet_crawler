class App
  hash_routes('institutions/update') do
    is true do |r|
      institution = Institution[@id]
      institution.display_name = r.params.fetch_values('display_name')

      if institution.modified? and institution.valid? and institution.save
        r.redirect request.referer
      else
        r.halt
      end
    end
  end
end
