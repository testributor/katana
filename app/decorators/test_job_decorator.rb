class TestJobDecorator < ApplicationDecorator
  include Models::HasRunningTime
  include Models::HasWorkerTime
  delegate_all

  def completed_at
    I18n.l(model.completed_at, format: :short) if model.completed_at?
  end
end
