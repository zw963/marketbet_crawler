class Task < Sequel::Model
  def done?
    is_done
  end
end
