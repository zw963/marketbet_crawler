require 'minitest/hooks/default'

class Minitest::HooksSpec
  def around
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) {super}
  end

  def around_all
    DB.transaction(rollback: :always) {super}
  end
end
