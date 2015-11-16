require 'test_helper'

class RetryOrCancelTestRunFeatureTest < Capybara::Rails::TestCase
  let(:_test_run) { FactoryGirl.create(:test_run) }
  let(:branch) { _test_run.tracked_branch }
  let(:project) { branch.project }
  let(:owner) { project.user }

  before do
    _test_run
    login_as owner, scope: :user
  end

  it "user is able to retry a complete test_run" do
    _test_run.update_column(:status, TestStatus::PASSED)
    _test_run.reload
    visit root_path
    page.must_have_content "Passed"
    find("input.btn-primary").click
    page.must_have_content "Pending"
  end

  it "user is able to retry a complete test_run" do
    _test_run.update_column(:status, TestStatus::FAILED)
    _test_run.reload
    visit root_path
    page.must_have_content "Failed"
    find("input.btn-primary").click
    page.must_have_content "Pending"
  end

  it "user is able to retry a complete test_run" do
    _test_run.update_column(:status, TestStatus::ERROR)
    _test_run.reload
    visit root_path
    page.must_have_content "Error"
    find("input.btn-primary").click
    page.must_have_content "Pending"
  end

  it "user is able to retry a cancelled test_run" do
    _test_run.update_column(:status, TestStatus::CANCELLED)
    _test_run.reload
    visit root_path
    page.must_have_content "Cancelled"
    find("input.btn-primary").click
    page.must_have_content "Pending"
  end

  it "user is able to cancel a pending test_run" do
    _test_run.update_column(:status, TestStatus::PENDING)
    _test_run.reload
    visit root_path
    page.must_have_content "Pending"
    find("input.btn-primary").click
    page.must_have_content "Cancelled"
  end

  it "user is able to cancel a running test_run" do
    _test_run.update_column(:status, TestStatus::RUNNING)
    _test_run.reload
    visit root_path
    page.must_have_content "Running"
    find("input.btn-primary").click
    page.must_have_content "Cancelled"
  end
end
