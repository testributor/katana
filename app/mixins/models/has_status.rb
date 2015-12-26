module Models::HasStatus
  def status_text
    object.status.text
  end

  def status_css_class
    object.status.css_class
  end

  def html_class
    TestStatus::STATUS_CLASS_MAP[object.status.code]
  end

  def unsuccessful
    object.status.unsuccessful?
  end
end
