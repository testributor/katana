class TestJobDecorator < ApplicationDecorator
  include Models::HasRunningTime
  include Models::HasWorkerTime
  delegate_all

  def completed_at
    I18n.l(model.completed_at, format: :short) if model.completed_at?
  end

  def demo_job_name
    matches = model.job_name.match(/([^\/]+?)_(feature_|controller_|integration_|service_)?test.rb$/)

    model.job_name.gsub(matches[1], "test_#{model.id}")
  end
end
