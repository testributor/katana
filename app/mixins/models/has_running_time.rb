module Models::HasRunningTime
  def total_running_time
    if object.total_running_time.present?
      "#{(object.total_running_time / 60).to_i} min " +
        "#{(object.total_running_time % 60).round} sec"
    end
  end
end
