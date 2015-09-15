class TestJobDecorator < ApplicationDecorator
  def completed_at
    I18n.l(model.completed_at, format: :short) if model.completed_at?
  end
end
