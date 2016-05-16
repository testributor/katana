class TestRunNotificationMailer < ApplicationMailer
  default from: "no-reply@testributor.com"

  def test_run_complete(test_run_id, recipient)
    @test_run = TestRun.find(test_run_id)
    @status = TestStatus::STATUS_MAP[@test_run.status.code]

    # TODO: status might have change if rerun
    mail(
      to: recipient,
      subject: "[#{@test_run.project.name}" +
      (@test_run.tracked_branch ? "/#{@test_run.tracked_branch.branch_name}]" : "") +
      " Build ##{@test_run.run_index} status is now \"#{@status}\"")
  end
end
