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
    # TODO: Manually triggered runs need a new notification type ("when MY builds complete")
    if @old_status != @new_status && new_status_terminal?
      if test_run.tracked_branch.present?
        previous_status = test_run.branch_previous_terminal_status
        notifiable_users =
          test_run.tracked_branch.notifiable_users(previous_status, @new_status)
      else
        notifiable_users =
          test_run.initiator.notify_on_manual_builds ? [test_run.initiator] : []
      end

      notifiable_users.each do |user|
        TestRunNotificationMailer.test_run_complete(test_run.id, user.email).
          deliver_later
      end
    end
  end

  def test_run
    @test_run ||= TestRun.find(@test_run_id)
  end
end
