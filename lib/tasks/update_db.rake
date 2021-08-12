namespace :db do
  require_relative '../../config/environment'

  task :update_institution_firm_id do
    Institution.all.each do |ins|
      firm = Firm.find_or_create(name: ins.name)
      ins.update(firm_id: firm.id)
    end
  end
end
