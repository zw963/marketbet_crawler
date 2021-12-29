require 'test_helper'

describe 'insider histories' do
  it 'test postgres read committed mode default lock' do
    create(:insider_history, number_of_shares: 200)

    thread1 = Thread.new do
      sleep rand(0.1..0.2)
      DB.transaction do
        user_transaction_1 = InsiderHistory.last
        user_transaction_1.update(number_of_shares: user_transaction_1.number_of_shares - 10)
      end
    end

    thread2 = Thread.new do
      sleep rand(0.1..0.2)
      DB.transaction do
        user_transaction_2 = InsiderHistory.last
        user_transaction_2.update(number_of_shares: user_transaction_2.number_of_shares - 10)
      end
    end

    thread1.join
    thread2.join

    assert_equal 180.0, InsiderHistory.last.number_of_shares
  end
end
