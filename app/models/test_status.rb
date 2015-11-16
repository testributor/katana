class TestStatus
  attr_reader :code
  PENDING = 0
  RUNNING = 1
  PASSED = 2
  FAILED = 3
  ERROR = 4
  CANCELLED = 5

  STATUS_MAP = {
    PENDING => 'Pending',
    RUNNING => 'Running',
    PASSED => "Passed",
    FAILED => 'Failed',
    ERROR => 'Error',
    CANCELLED => 'Cancelled'
  }

  def initialize(code)
    @code = code
  end

  def pending?
    @code == PENDING
  end

  def running?
    @code == RUNNING
  end

  def passed?
    @code == PASSED
  end

  def failed?
    @code == FAILED
  end

  def error?
    @code == ERROR
  end

  def cancelled?
    @code == CANCELLED
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
    when PASSED
      'label label-success'
    when FAILED
      'label label-danger'
    when ERROR
      'label label-danger'
    end
  end
end
