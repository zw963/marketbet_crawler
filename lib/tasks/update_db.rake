namespace :db do
  task :update_institution_firm_id do
    require_relative '../../config/environment'
    Institution.all.each do |ins|
      firm = Firm.find_or_create(name: ins.name)
      ins.update(firm_id: firm.id)
    end
  end
end
