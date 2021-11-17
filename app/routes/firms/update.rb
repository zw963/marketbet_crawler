class App
  hash_routes('firms/update') do
    is true do |r|
      firm = Firm[@id]
      firm.display_name = r.params.fetch_values('display_name')
      
      if firm.modified? and firm.valid? and firm.save
        r.redirect request.referrer
      else
        r.halt
      end
    end
  end
end
