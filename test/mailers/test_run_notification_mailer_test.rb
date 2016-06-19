require 'test_helper'

class TestRunNotificationMailerTest < ActionMailer::TestCase
  test "test_run_complete" do
    failed_build = FactoryGirl.create(:testributor_run, :failed)
    failed_test_job = FactoryGirl.create(:testributor_job,
                                         test_run: failed_build,
                                         result: "this is the failure itself",
                                         status: TestStatus::FAILED)
    email =
      TestRunNotificationMailer.test_run_complete(failed_build.id, 'test@example.com')
 
    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end
 
    # Test the body of the sent email contains what we expect it to
    email.from.must_equal ['no-reply@testributor.com']
    email.to.must_equal ['test@example.com']
    email.subject.must_match(/\[.+\/.+\] Build #\d+ status is now "Failed"/)
    email.body.to_s.must_match /this is the failure itself/
  end
end
