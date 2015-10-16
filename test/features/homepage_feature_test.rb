require 'test_helper'

class HomepageFeatureTest < Capybara::Rails::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:owner) { project.user }

  describe "when user is logged in" do
    before do
      project
      owner.update_column(:projects_limit, 2)
      owner.reload
    end

    it "displays the branches along with statuses", js: true do
      branches = [
        {
          commit_sha: "344ads",
          status: TestStatus::PENDING, name: 'pending-branch'
        },
        {
          commit_sha: "0f542",
          status: TestStatus::RUNNING, name: 'running-branch'
        },
        {
          commit_sha: "934ni",
          status: TestStatus::COMPLETE, name: 'passed-branch'
        },
        {
          commit_sha: "a0acl",
          status: TestStatus::CANCELLED, name: 'cancelled-branch'
        }
      ]

      branches.each do |branch|
        tracked_branch = TrackedBranch.new({branch_name: branch[:name]})
        tracked_branch.test_jobs.
          build(commit_sha: branch[:commit_sha], status: branch[:status])
        project.tracked_branches << tracked_branch
      end

      project.save!
      login_as owner, scope: :user
      visit dashboard_path

      page.must_have_content "Pending"
      page.must_have_content "Passed"
      page.must_have_content "Cancelled"
      page.must_have_content "Running"
    end
  end
end
