class Time
  def is_today?
    beginning_of_today = Date.today.to_time
    beginning_of_tomorrow = (Date.today + 1).to_time

    (beginning_of_today...beginning_of_tomorrow).cover?(self)
  end
end
