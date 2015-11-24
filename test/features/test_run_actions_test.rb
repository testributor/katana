require 'test_helper'

class TestRunActionsFeatureTest < Capybara::Rails::TestCase
  let(:_test_run) { FactoryGirl.create(:testributor_run) }
  let(:owner) { _test_run.project.user }
  let(:_test_job) { FactoryGirl.create(:testributor_job, test_run: _test_run) }

  before do
    _test_job.test_run.project.
      project_files << FactoryGirl.create(:project_file, path: ProjectFile::JOBS_YML_PATH)
    login_as owner, scope: :user
    visit project_branch_test_runs_path(project_id: _test_run.project.id,
                                        branch_id: _test_run.tracked_branch.id)
  end

  describe 'when a user visits the test_runs index' do
    it 'displays the retry action' do
      page.must_have_content('Retry')
    end

    it 'displays the cancel action' do
      page.must_have_content('Cancel')
    end
  end

  describe 'when a user clicks on retry button' do
    it 'must recreate all test_jobs', js: true do
      TestRun.any_instance.stubs(:project_file_names).
        returns(['test/controllers/shitty_test.rb'])
      old_test_job = _test_job.id
      _test_run.test_jobs.pluck(:id).must_equal [_test_job.id]
      page.first('td .btn.btn-icon.btn-success').click
      _test_run.test_jobs.pluck(:id).must_equal [old_test_job + 1]
    end
  end

  describe 'when a user clicks on delete button' do
    it 'must delete all test_jobs', js: true do
      _test_run.test_jobs.pluck(:id).must_equal [_test_job.id]
      page.first('td .btn.btn-danger').click
      TestRun.cancelled.count.must_equal 1
    end
  end
end
