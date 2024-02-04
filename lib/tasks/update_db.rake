namespace :db do
  task :db_rollback do
    require_relative '../../config/environment'
    # DB.rollback_on_exit
  end
  task :update_institution_histories_institution_id do
    InstitutionHistory.all do |ins|
      institution = Institution.find_or_create(name: ins.name)
      ins.update(institution_id: institution.id)
    end
  end

  task :update_insider_history_insider_id do
    # 因为使用了 stream, 所以这里必须用 all 方法才工作。
    # all 会预加载所有数据，然后，再执行 block 中的 query.
    InsiderHistory.all do |ih|
      insider = Insider.find_or_create(name: ih.name)
      ih.update(insider_id: insider.id)
    end
  end

  task :update_insider_1 do
    # 因为使用了 stream, 所以这里必须用 all 方法才工作。
    # all 会预加载所有数据，然后，再执行 block 中的 query.
    Insider.all do |e|
      insider_histories = InsiderHistory.where(insider_id: e.id)
      last = insider_histories.order(:date).last
      e.update(
        last_trade_date:       last.date,
        last_trade_stock:      last.stock.name,
        number_of_trade_times: insider_histories.count,
        trade_on_stock_amount: insider_histories.group_and_count(:stock_id).all.size
      )
    end
  end

  task :update_insider_2 do
    require_relative '../../config/environment'

    Insider.grep(:name, '%.%').all do |e|
      new_name = e.name.delete('.')
      if (exists = Insider.find(name: new_name))
        puts "exists #{exists}, deleting it"
        e.insider_histories_dataset.destroy
        e.destroy
      else
        puts 'not exists, update it'
        e.update(name: new_name)
      end
    end
  end

  task update_stock_1: :db_rollback do
    # 因为使用了 stream, 所以这里必须用 all 方法才工作。
    # all 会预加载所有数据，然后，再执行 block 中的 query.
    Stock.all do |e|
      e.update(name: "#{e.exchange.name}/#{e.name}")
    end
  end
end
