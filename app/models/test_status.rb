class TestStatus
  PENDING = 0
  RUNNING = 1
  COMPLETE = 2
  CANCELLED = 3

  STATUS_MAP = {
    PENDING => 'Pending',
    RUNNING => 'Running',
    COMPLETE => 'Complete',
    CANCELLED => 'Cancelled'
  }
end
