class App
  hash_routes('firms/update') do
    is true do |r|
      firm = Firm[@id]
      firm.display_name, original_path = r.params.fetch_values('display_name', 'original_path')
      
      if firm.modified? and firm.valid? and firm.save
        r.redirect original_path
      else
        r.halt
      end
    end
  end
end
