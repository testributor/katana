require 'test_helper'

class TestRunTest < ActiveSupport::TestCase
  let(:_test_run) { FactoryGirl.create(:testributor_run, :passed) }

  describe "validations" do
    it "does not allow empty project_id" do
      _test_run.project_id = nil
      _test_run.wont_be :valid?
      _test_run.errors[:project_id].must_equal ["can't be blank"]
    end

    it "does not allow empty commit_sha" do
      _test_run.commit_sha = nil
      _test_run.wont_be :valid?
      _test_run.errors[:commit_sha].must_equal ["can't be blank"]
    end
  end

  describe "before_validation -> set_run_index" do
    let(:project) { FactoryGirl.create(:project) }
    let(:tracked_branch) do
      FactoryGirl.create(:tracked_branch, project: project)
    end

    describe "when previous runs exist" do
      before do
        FactoryGirl.create(:testributor_run, run_index: 23,
                           tracked_branch: tracked_branch)
      end
      it "sets the run_index to the next index" do
        run = tracked_branch.test_runs.build
        run.valid?
        run.run_index.must_equal 24
      end
    end

    describe "when no previous runs exist" do
      it "set the run_index to 1" do
        run = tracked_branch.test_runs.build
        run.valid?
        run.run_index.must_equal 1
      end
    end

    describe "when no there is no tracked_branch associated" do
      let(:branch_associated_run) do
        FactoryGirl.create(:testributor_run, project: project,
                           tracked_branch: tracked_branch)
      end

      let(:non_associated_runs) do
        FactoryGirl.create_list(:testributor_run, 3, project: project,
                           tracked_branch: nil)
      end

      it "sets the index among the rest of the non-branch-associated runs" do
        branch_associated_run.run_index.must_equal 1
        non_associated_runs
        non_associated_runs.map(&:run_index).sort.must_equal [1,2,3]

        _test_run = FactoryGirl.build(:testributor_run, project: project,
                          tracked_branch: nil)
        _test_run.valid?
        _test_run.run_index.must_equal 4
      end
    end
  end

  describe "#cancel_queued_runs_of_same_branch" do
    let(:existing_run) do
      FactoryGirl.create(:testributor_run, :queued)
    end

    describe "when a build exists and has status QUEUED and a new build is added" do
      it "cancels the previous build" do
        new_run = FactoryGirl.build(:testributor_run,
          project: existing_run.project,
          tracked_branch: existing_run.tracked_branch)
        project = existing_run.project
        project.test_runs.map(&:id).must_equal [existing_run.id]
        new_run.save
        project.test_runs.cancelled.reload.map(&:id).must_equal [existing_run.id]
        project.test_runs.where(status: TestStatus::SETUP).map(&:id).
          must_equal([new_run.id])
      end
    end

    describe "when a build exists and has status SETUP" do
      let(:existing_run) do
        FactoryGirl.create(:testributor_run, :setup)
      end

      it "cancels the previous build" do
        new_run = FactoryGirl.build(:testributor_run,
          project: existing_run.project,
          tracked_branch: existing_run.tracked_branch)
        project = existing_run.project
        project.test_runs.map(&:id).must_equal [existing_run.id]
        new_run.save
        project.test_runs.cancelled.reload.map(&:id).must_equal [existing_run.id]
        project.test_runs.where(status: TestStatus::SETUP).map(&:id).
          must_equal([new_run.id])
      end
    end
  end

  describe "#cancel_test_jobs" do
    subject { FactoryGirl.create(:testributor_run, :passed) }
    before do
      subject.test_jobs.create!(command: "ls", status: TestStatus::QUEUED)
      subject.test_jobs.create!(command: "ls", status: TestStatus::QUEUED)
    end

    it "cancels the test_jobs when it is cancelled" do
      subject.status = TestStatus::CANCELLED
      subject.save!
      subject.test_jobs.reload.pluck(:status).uniq.must_equal [TestStatus::CANCELLED]
    end
  end

  describe "previous_run" do
    let(:project) { FactoryGirl.create(:project) }
    let(:branch_1) { FactoryGirl.create(:tracked_branch, project: project) }
    let(:branch_2) { FactoryGirl.create(:tracked_branch, project: project) }

    subject do
      FactoryGirl.create(:testributor_run, :passed, tracked_branch: branch_1,
        commit_sha: '3333', sha_history: ['3333', '2222', '1111', '0000'])
    end

    describe "when there are previous TestRuns that match the history" do
      let(:previous_run) do
        FactoryGirl.create(:testributor_run, :passed, tracked_branch: branch_2,
          commit_sha: '1111')
      end
      let(:older_commit_previous_run) do
        FactoryGirl.create(:testributor_run, :passed, tracked_branch: branch_1,
          commit_sha: '0000')
      end
      before do
        older_commit_previous_run
        previous_run
      end

      it "returns the first match" do
        subject.previous_run.must_equal previous_run
      end
    end

    describe "when there are not previous TestRuns that match the history" do
      it "returns nil" do
        subject.previous_run.must_equal nil
      end
    end
  end

  describe "most_relevant_run" do
    let(:branch) { FactoryGirl.create(:tracked_branch) }

    subject do
      FactoryGirl.create(:testributor_run, :passed, tracked_branch: branch,
        commit_sha: '3333', sha_history: ['3333', '2222', '1111', '0000'])
    end

    let(:most_recent_non_previous_run) do
      FactoryGirl.create(:testributor_run, :passed, tracked_branch: branch,
        commit_sha: 'nothing_to_do_with_the_history_sha')
    end

    before { most_recent_non_previous_run }

    describe "when there are previous TestRuns that match the history" do
      let(:previous_run) do
        FactoryGirl.create(:testributor_run, :passed, tracked_branch: branch,
          commit_sha: '1111')
      end

      before do
        Timecop.travel(1.month.ago) { previous_run }
      end

      it "returns the first match even when more recent exist" do
        subject.most_relevant_run.must_equal previous_run
      end
    end

    describe "when there are not previous TestRuns that match the history" do
      it "returns the most recent run" do
        subject.most_relevant_run.must_equal most_recent_non_previous_run
      end

      describe "when there are no TestRuns at all" do
        before do
          TestRunStatusEmailNotificationService.any_instance.stubs(:schedule_notifications).returns(true)
          most_recent_non_previous_run.destroy
        end

        it 'returns nil' do
          subject.most_relevant_run.must_be :nil?
        end
      end
    end
  end

  describe "retry?" do
    subject { FactoryGirl.build(:testributor_run) }

    it "returns false when TestRun is queued" do
      subject.status = TestStatus::QUEUED
      subject.wont_be :retry?
    end

    it "returns false when TestRun is running" do
      subject.status = TestStatus::RUNNING
      subject.wont_be :retry?
    end

    it "returns false when TestRun is cancelled" do
      subject.status = TestStatus::CANCELLED
      subject.wont_be :retry?
    end

    it "returns true when TestRun is passed" do
      subject.status = TestStatus::PASSED
      subject.must_be :retry?
    end

    it "returns true when TestRun is failed" do
      subject.status = TestStatus::FAILED
      subject.must_be :retry?
    end

    it "returns true when TestRun is error" do
      subject.status = TestStatus::ERROR
      subject.must_be :retry?
    end
  end

  describe "branch_previous_terminal_status" do
    let(:project) { FactoryGirl.create(:project) }
    describe "when no tracked_branch is set" do
      subject do
        FactoryGirl.build(:testributor_run, project: project,
                          tracked_branch: nil)
      end
      it "returns nil" do
        subject.branch_previous_terminal_status.must_equal nil
      end
    end

    describe "when a branch is set" do
    end
  end

  describe "update_status" do
    let(:branch) { FactoryGirl.create(:tracked_branch) }

    let(:_test_run) do
      FactoryGirl.create(:testributor_run, tracked_branch: branch,
                        status: TestStatus::QUEUED)
    end

    let(:_test_job) do
      FactoryGirl.create(:testributor_job, test_run: _test_run,
                         status: TestStatus::QUEUED)
    end

    describe "when the run's status does not change" do
      before { _test_job }

      it "does not try to send any emails" do
        branch.expects(:notifiable_users).never
        _test_run.send(:update_status)
        perform_enqueued_jobs do
          _test_run.save
        end
      end
    end

    describe "when the run's status changes" do
      describe "when the new status is not terminal" do
        before do
          Octokit::Client.any_instance.stubs(:create_status).returns(nil)
          _test_job.update_column(:status, TestStatus::RUNNING)
        end

        it "does not send any emails" do
          branch.expects(:notifiable_users).never
          _test_run.update_status
          perform_enqueued_jobs do
            VCR.use_cassette (self.class.name + "::" + self.method_name), match_requests_on: [:host, :method] do
              _test_run.save
            end
          end
          ActionMailer::Base.deliveries.length.must_equal 0
        end
      end

      describe "when the new status is terminal" do
        before do
          _test_job.update_column(:status, TestStatus::PASSED)
          Octokit::Client.any_instance.stubs(:create_status).returns(nil)
          TrackedBranch.any_instance.stubs(:notifiable_users).returns([
            User.new(email: 'harry_potter@example.com'),
            User.new(email: 'lara_croft@example.com')
          ])
        end

        it "sends emails to all recipients returned by the branch's notifiable_users" do

          _test_run.send(:update_status)
          perform_enqueued_jobs do
            VCR.use_cassette (self.class.name + "::" + self.method_name), match_requests_on: [:host, :method] do
               _test_run.save
            end
          end

          ActionMailer::Base.deliveries.length.must_equal 2
          ActionMailer::Base.deliveries.map(&:to).sort.must_equal([
            ['harry_potter@example.com'],
            ['lara_croft@example.com']
          ])
        end
      end
    end
  end

  describe "notifiable_users" do
    let(:project) { FactoryGirl.create(:project) }
    let(:master_branch) do
      FactoryGirl.create(
        :tracked_branch, branch_name: "master", project: project)
    end

    let(:user_matching_branch_setting) do
      user = FactoryGirl.create(:user)
      project.members << user
      user.project_participations.first.branch_notification_settings.create!(
        tracked_branch: master_branch,
        notify_on: BranchNotificationSetting::NOTIFY_ON_MAP.invert[:always]
      )

      user
    end

    let(:user_matching_own_build_notification_settings) do
      user = FactoryGirl.create(:user)
      project.members << user
      participation = user.project_participations.first
      participation.my_builds_notify_on =
        BranchNotificationSetting::NOTIFY_ON_MAP.invert[:always] 
      participation.save

      user
    end

    let(:_test_run) do
      FactoryGirl.create(:testributor_run, project: project,
        tracked_branch: master_branch,
        initiator: user_matching_own_build_notification_settings)
    end

    before do
      user_matching_own_build_notification_settings
      user_matching_branch_setting

      # Disable branch notification for all other users
      BranchNotificationSetting.where(
        "project_participation_id != ?",
        user_matching_branch_setting.project_participations.first.id).update_all(
          notify_on: BranchNotificationSetting::NOTIFY_ON_MAP.invert[:never])
    end

    it "returns matching users based on BranchNotificationSettings and ProjectParticipation" do
      _test_run.notifiable_users(TestStatus::FAILED, TestStatus::PASSED).
        map(&:email).sort.must_equal(
          [user_matching_own_build_notification_settings,
           user_matching_branch_setting, project.user].map(&:email).sort
        )


      # Now verify that if works by changing the setting
      user_matching_own_build_notification_settings.project_participations.first.
        update_column(:my_builds_notify_on,
          BranchNotificationSetting::NOTIFY_ON_MAP.invert[:never])

      _test_run.notifiable_users(TestStatus::FAILED, TestStatus::PASSED).
        map(&:email).sort.must_equal(
          [user_matching_branch_setting, project.user].map(&:email).sort
        )

      # Now disable the rest of the users
      never_setting = BranchNotificationSetting::NOTIFY_ON_MAP.invert[:never]
      BranchNotificationSetting.update_all(notify_on: never_setting)
      ProjectParticipation.update_all(my_builds_notify_on: never_setting,
        others_builds_notify_on: never_setting)

      _test_run.notifiable_users(TestStatus::FAILED, TestStatus::PASSED).
        must_equal([])

      # Now simply enable a notification based on other members
      user = project.members.where("users.id != ?", _test_run.initiator_id).first
      user.project_participations.first.update_column(:others_builds_notify_on,
        BranchNotificationSetting::NOTIFY_ON_MAP.invert[:always])

      _test_run.notifiable_users(TestStatus::FAILED, TestStatus::PASSED).
        must_equal([user])
    end
  end
end
