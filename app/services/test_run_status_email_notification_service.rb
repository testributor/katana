class TestRunStatusEmailNotificationService

  def initialize(test_run_id, old_status, new_status)
    @test_run_id = test_run_id
    @old_status = old_status
    @new_status = new_status
  end

  def new_status_terminal?
    [TestStatus::ERROR, TestStatus::FAILED, TestStatus::PASSED, TestStatus::CANCELLED].include?(@new_status)
  end

  def schedule_notifications
    if @old_status != @new_status && new_status_terminal?
      notifiable_users = test_run.notifiable_users(@old_status, @new_status)
      notifiable_users.each do |user|
        # TODO: Cache the status because until the email is sent, someone might
        # have retried a job. That might result in saying 'Build #3 completed with status "Running"'
        # in the email.
        TestRunNotificationMailer.test_run_complete(test_run.id, user.email).
          deliver_later
      end
    end
  end

  def test_run
    @test_run ||= TestRun.find(@test_run_id)
  end
end
