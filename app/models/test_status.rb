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
      'label label-default'
    when PENDING
      'label label-info'
    when RUNNING
      'label label-running'
    when COMPLETE
      @failed ? 'label label-danger' : 'label label-success'
    end
  end
end
