class TestStatus
  attr_reader :code
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

  def initialize(code, failed)
    @code = code
    @failed = failed
  end

  def cta_text
    case @code
    when PENDING, RUNNING
      "cancel"
    else
      "retry"
    end
  end

  def status_to_set
    if cta_text == "cancel"
      CANCELLED
    else
      PENDING
    end
  end

  def text
    if @code == COMPLETE
      return @failed ? 'Failed' : 'Passed'
    end

    STATUS_MAP[@code]
  end

  def css_class
    case @code
    when CANCELLED
      'cancelled'
    when PENDING
      'pending'
    when RUNNING
      'running'
    when COMPLETE
      @failed ? 'failed' : 'success'
    end
  end
end
