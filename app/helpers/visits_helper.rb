module VisitsHelper
  def rounded_current_time
    time = Time.current
    minutes = time.min
    rounded_minutes = (minutes / 15.0).round * 15

    time = time.change(
      min: rounded_minutes,
      sec: 0
    )

    time.in_time_zone(Time.zone).strftime("%H:%M")
  end
end
