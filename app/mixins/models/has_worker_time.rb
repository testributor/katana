module Models::HasWorkerTime
  def worker_command_run_seconds
    if object.worker_command_run_seconds.present?
      "#{object.worker_command_run_seconds.round(2)} seconds"
    end
  end

  def avg_worker_command_run_seconds
    if object.avg_worker_command_run_seconds.present?
      "#{object.avg_worker_command_run_seconds.round(2)} seconds"
    end
  end
end
