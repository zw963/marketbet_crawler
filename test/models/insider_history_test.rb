require 'test_helper'

describe 'insider histories' do
  it 'test postgres read committed mode default lock' do
    if DB.in_transaction?
      skip '测试 pg read committed mode 不支持在 transaction 模式下运行'
    else
      create(:insider_history, number_of_shares: 200)

      thread1 = Thread.new do
        sleep rand(0.1..0.2)
        DB.transaction do
          insdier_history_1 = InsiderHistory.last
          insdier_history_1.update(number_of_shares: insdier_history_1.number_of_shares - 10)
        end
      end

      thread2 = Thread.new do
        sleep rand(0.1..0.2)
        DB.transaction do
          insider_history_2 = InsiderHistory.last
          insider_history_2.update(number_of_shares: insider_history_2.number_of_shares - 10)
        end
      end

      thread1.join
      thread2.join

      assert_equal 180.0, InsiderHistory.last.number_of_shares
    end
  end
end
