module ApplicationHelper
  def brand_name
    'Testributor'
  end

  def job_class(status)
    case status
    when 'Pending'
      'warning'
    when 'Passed'
      'success'
    when 'Failed'
      'danger'
    else
      ''
    end
  end
end
