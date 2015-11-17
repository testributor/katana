class TestRunDecorator < ApplicationDecorator
  delegate_all

  def commit_message
    if model.commit_message.present?
      "#{h.truncate(model.commit_message.split("\n")[0], length: 80, separator: ' ')} (#{model.commit_sha[0...6]})"
    else
      model.commit_sha
    end
  end
end
