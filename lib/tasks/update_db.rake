namespace :db do
  task :update_institution_firm_id do
    require_relative '../../config/environment'
    Institution.all do |ins|
      firm = Firm.find_or_create(name: ins.name)
      ins.update(firm_id: firm.id)
    end
  end

  task :update_insider_history_insider_id do
    require_relative '../../config/environment'
    # 因为使用了 stream, 所以这里必须用 all 方法才工作。
    # all 会预加载所有数据，然后，再执行 block 中的 query.
    InsiderHistory.all do |ih|
      insider = Insider.find_or_create(name: ih.name)
      ih.update(insider_id: insider.id)
    end
  end
end
