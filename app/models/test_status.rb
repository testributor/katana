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

  def initialize(status, failed)
    @status = status
    @failed = failed
  end

  def text
    if @status == COMPLETE
      return @failed ? 'Failed' : 'Passed'
    end

    STATUS_MAP[@status]
  end

  def css_class
    case @status
    when PENDING
      'pending'
    when RUNNING
      'running'
    when COMPLETE
      @failed ? 'failed' : 'success'
    end
  end
end
