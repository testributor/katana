require 'test_helper'

class TrackedBranchTest < ActiveSupport::TestCase
  let(:tracked_branch) { FactoryGirl.create(:tracked_branch) }

  describe "#cleanup_old_runs" do
    it "preserves only OLD_RUNS_LIMIT most recent(by created_at) TestRuns" do
      oldest_test_run = FactoryGirl.create(:testributor_run,
                                          tracked_branch: tracked_branch,
                                          created_at: 3.days.ago)
      FactoryGirl.create_list(:testributor_run,
                              TrackedBranch::OLD_RUNS_LIMIT,
                              tracked_branch: tracked_branch,
                              created_at: Time.now)
      tracked_branch.cleanup_old_runs

      tracked_branch.test_runs.count.must_equal TrackedBranch::OLD_RUNS_LIMIT
      tracked_branch.test_runs.pluck(:id).wont_include oldest_test_run.id
    end

    it "doesn't destroy any run if test_runs.count <= OLD_RUNS_LIMIT" do
      old_count = TrackedBranch::OLD_RUNS_LIMIT - 1
      FactoryGirl.create_list(:testributor_run, old_count,
                              tracked_branch: tracked_branch)
      tracked_branch.cleanup_old_runs

      tracked_branch.test_runs.count.must_equal old_count
    end
  end

  describe "when a new branch is created" do
    let(:project) { FactoryGirl.create(:project) }
    let(:participants) do
      2.times { project.members << FactoryGirl.create(:user) }
      project.project_participations.each_with_index do |participation, index|
        participation.new_branch_notify_on = index
        participation.save!
      end

      project.members
    end

    before { participants }

    it "creates branch_notification_settings for all project's members" do
      tracked_branch = FactoryGirl.build(:tracked_branch, project: project)
      tracked_branch.save!
      tracked_branch.branch_notification_settings.count.must_equal 3
      tracked_branch.branch_notification_settings.
        map{|n| n.project_participation.user_id}.sort.
        must_equal(project.members.map(&:id).sort)

      tracked_branch.branch_notification_settings.map(&:notify_on).sort.
        must_equal([0,1,2])
    end
  end

  describe "notifiable_users" do
    let(:notify_on_map) { BranchNotificationSetting::NOTIFY_ON_MAP.invert }
    let(:never_user) do
      user = FactoryGirl.create(:user)
      tracked_branch.project.reload.members << user
      user.project_participations.first.
        branch_notification_settings.first.
        update_column(:notify_on, notify_on_map[:never])

      user
    end
    let(:always_user) do
      user = FactoryGirl.create(:user)
      tracked_branch.project.reload.members << user
      user.project_participations.first.
        branch_notification_settings.first.
        update_column(:notify_on, notify_on_map[:always])

      user
    end
    let(:status_change_user) do
      user = FactoryGirl.create(:user)
      tracked_branch.project.reload.members << user
      user.project_participations.first.
        branch_notification_settings.first.
        update_column(:notify_on, notify_on_map[:status_change])

      user
    end
    let(:every_failure_user) do
      user = FactoryGirl.create(:user)
      tracked_branch.project.reload.members << user
      user.project_participations.first.
        branch_notification_settings.first.
        update_column(:notify_on, notify_on_map[:every_failure])

      user
    end

    before do
      always_user; never_user; status_change_user; every_failure_user
    end

    describe "when status has changed" do
      let(:old_status) { TestStatus::QUEUED }
      let(:new_status) { TestStatus::FAILED }

      it "does not include 'never' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          wont_include(never_user)
      end

      it "includes 'always' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          must_include(always_user)
      end

      it "includes 'status_change' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          must_include(status_change_user)
      end
    end

    describe "when new status is FAIL" do
      let(:old_status) { TestStatus::QUEUED }
      let(:new_status) { TestStatus::FAILED }

      it "does not include 'never' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          wont_include(never_user)
      end

      it "includes 'always' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          must_include(always_user)
      end

      it "includes 'every_failure' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          must_include(every_failure_user)
      end
    end
    describe "when new status is ERROR" do
      let(:old_status) { TestStatus::QUEUED }
      let(:new_status) { TestStatus::ERROR }

      it "does not include 'never' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          wont_include(never_user)
      end

      it "includes 'always' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          must_include(always_user)
      end

      it "includes 'every_failure' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          must_include(every_failure_user)
      end
    end

    describe "when status is not changed" do
      let(:old_status) { TestStatus::PASSED }
      let(:new_status) { TestStatus::PASSED }

      it "does not include 'never' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          wont_include(never_user)
      end

      it "includes 'always' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          must_include(always_user)
      end

      it "does not include 'status_change' user" do
        tracked_branch.notifiable_users(old_status, new_status).
          wont_include(status_change_user)
      end
    end
  end
end
