require 'test_helper'

class TestRunIndexFeatureTest < Capybara::Rails::TestCase
  describe 'when visiting the TestRun#index ' do
    let(:tracked_branch) { FactoryGirl.create(:tracked_branch) }

    before do
      count = 0
      start_id = 20000

      while count < 10 do
        test_run = FactoryGirl.build(:testributor_run,
          project_id: tracked_branch.project_id,
          tracked_branch_id: tracked_branch.id)
        test_run.id = start_id

        count += 1 if test_run.save
        start_id += 1
      end

      login_as tracked_branch.project.user, scope: :user
    end

    it 'should display run indexes (not ids) for each test run', js: true do
      visit project_test_runs_path(tracked_branch.project_id,
        branch: tracked_branch.branch_name)

      page.must_have_content('#1')
      page.must_have_content('#2')
      page.must_have_content('#3')
      page.must_have_content('#4')
      page.must_have_content('#5')
      page.must_have_content('#6')
      page.must_have_content('#7')
      page.must_have_content('#8')
      page.must_have_content('#9')
      page.must_have_content('#10')
    end
  end
end
