class AdminNotificationMailer < ApplicationMailer
  default from: "admin_notifications@testributor.com",
    to: "devs@testributor.com"

  def inconsistent_state_test_jobs_notification
    mail(subject: 'Inconsistent state TestJobs exist')
  end
end
