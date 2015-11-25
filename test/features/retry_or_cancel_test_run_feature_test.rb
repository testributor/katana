require 'test_helper'

class RetryOrCancelTestRunFeatureTest < Capybara::Rails::TestCase
  let(:_test_run) { FactoryGirl.create(:testributor_run) }
  let(:_test_job) { FactoryGirl.create(:testributor_job, test_run: _test_run) }
  let(:_project_file) { FactoryGirl.create(:testributor_job, test_run: _test_rcun) }
  let(:owner) { _test_run.project.user }

  before do
    TestRun.any_instance.stubs(:project_file_names).
      returns(['test/controllers/shitty_test.rb'])
    _test_job.test_run.project.
      project_files << FactoryGirl.create(:project_file, path: ProjectFile::JOBS_YML_PATH)
    login_as owner, scope: :user
  end

  it "user is able to retry a complete test_run" do
    _test_run.update_column(:status, TestStatus::PASSED)
    _test_run.reload
    visit root_path
    page.must_have_content "Passed"
    page.wont_have_selector ".btn-success"
  end

  it "user is able to retry a complete test_run" do
    _test_run.update_column(:status, TestStatus::FAILED)
    _test_run.reload
    visit root_path
    page.must_have_content "Failed"
    find(".btn-success").click
    page.must_have_content "Queued"
  end

  it "user is able to retry a complete test_run" do
    _test_run.update_column(:status, TestStatus::ERROR)
    _test_run.reload
    visit root_path
    page.must_have_content "Error"
    find(".btn-success").click
    page.must_have_content "Queued"
  end

  it "user is able to retry a cancelled test_run" do
    _test_run.update_column(:status, TestStatus::CANCELLED)
    _test_run.reload
    visit root_path
    page.must_have_content "Cancelled"
    find(".btn-success").click
    page.must_have_content "Queued"
  end

  it "user is able to cancel a queued test_run" do
    _test_run.update_column(:status, TestStatus::QUEUED)
    _test_run.reload
    visit root_path
    page.must_have_content "Queued"
    find(".btn-danger").click
    page.must_have_content "Cancelled"
  end

  it "user is able to cancel a running test_run" do
    _test_run.update_column(:status, TestStatus::RUNNING)
    _test_run.reload
    visit root_path
    page.must_have_content "Running"
    find(".btn-danger").click
    page.must_have_content "Cancelled"
  end
end
