require 'test_helper'

class TestRunTest < ActiveSupport::TestCase
  let(:_test_run) { FactoryGirl.create(:testributor_run) }

  describe "#cancel_test_jobs" do
    subject { FactoryGirl.create(:testributor_run) }
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

  describe "#total_running_time" do
    it "returns total time when all times exist" do
      times = [
        { started_at: 1.hour.ago, completed_at: 30.minutes.ago },
        { started_at: 1.hour.ago, completed_at: 15.minutes.ago }
      ]
      create_times(times, _test_run)
      _test_run.save!

      _test_run.total_running_time.must_equal 45.minutes
    end

    it "returns total time when completed_at is missing" do
      times = [
        { started_at: 30.minutes.ago, completed_at: nil },
        { started_at: 1.hour.ago, completed_at: 15.minutes.ago },
        { started_at: 2.hours.ago, completed_at: nil }
      ]
      create_times(times, _test_run)
      _test_run.save!

      _test_run.total_running_time.must_equal 2.hours
    end

    it "returns nil when TestJob doesn't exist" do
      _test_run.total_running_time.must_equal nil
    end

    it "returns nil when completed_at, started_at are missing" do
      times = [
        { started_at: nil, completed_at: nil },
      ]
      create_times(times, _test_run)
      _test_run.save!

      _test_run.total_running_time.must_equal nil
    end
  end

  describe "#jobs_yml" do
    subject { FactoryGirl.create(:testributor_run) }
    let(:client) { Octokit::Client.new(access_token: "some_token") }
    let(:file) do
      file = mock
      file.stubs(:content).returns(Base64.encode64("repo version"))

      file
    end

    before do
      subject.stubs(:github_client).returns(client)
    end

    describe "when file exists both in project_files and repo" do
      before do
        # project_files version
        subject.project.project_files.create(
          path: TestRun::JOBS_YML_PATH, contents: "project_files version")

        # Stub repo version
        client.stubs(:contents).
          with(subject.tracked_branch.project.repository_id,
               {path: TestRun::JOBS_YML_PATH, ref: subject.commit_sha}).
          returns(file)
      end

      it "returns the repo version" do
        subject.jobs_yml.must_equal 'repo version'
      end
    end

    describe "when file only exists in the repo" do
      before do
        # Stub repo version
        client.stubs(:contents).
          with(subject.tracked_branch.project.repository_id,
               {path: TestRun::JOBS_YML_PATH, ref: subject.commit_sha}).
          returns(file)
      end

      it "returns the repo version" do
        subject.jobs_yml.must_equal 'repo version'
      end
    end

    describe "when file only exists in project_files" do
      before do
        # project_files version
        subject.project.project_files.create(
          path: TestRun::JOBS_YML_PATH, contents: "project_files version")

        client.stubs(:contents).
          with(subject.tracked_branch.project.repository_id,
               {path: TestRun::JOBS_YML_PATH, ref: subject.commit_sha}).
          raises(Octokit::NotFound)
      end

      it "returns the project_files version" do
        subject.jobs_yml.must_equal 'project_files version'
      end
    end

    describe "when file does not exist" do
      before do
        # Stub repo version
        client.stubs(:contents).
          with(subject.tracked_branch.project.repository_id,
               {path: TestRun::JOBS_YML_PATH, ref: subject.commit_sha}).
          raises(Octokit::NotFound)
      end

      it "returns nil" do
        subject.jobs_yml.must_be :nil?
      end
    end
  end

  describe "build_test_jobs" do
    subject { FactoryGirl.create(:testributor_run) }

    before do
      subject.stubs(:project_file_names).returns(
        ['test/models/user_test.rb', 'test/features/funny_feature_test.rb'])
      subject.stubs(:jobs_yml).returns(yml)
    end

    describe 'when yml has syntax error' do
      let(:yml) do
        <<-YML
          invalid_ymls_suck
          each:
            pattern: '.*funny.*'
            command: "bin/rake test %{file}"
        YML
      end

      it "returns errors" do
        subject.build_test_jobs.must_equal({ errors: 'yml syntax error'})
      end
    end

    describe 'when "each" key exists' do
      let(:yml) do
        <<-YML
          each:
            pattern: '.*funny.*'
            command: "bin/rake test %{file}"
        YML
      end

      describe 'but no "pattern" exists' do
        let(:yml) do
          <<-YML
            each:
              command: 'some command'
          YML
        end

        it "returns errors" do
          subject.build_test_jobs.
            must_equal({ errors: '"each" block defined but no "pattern"'})
        end
      end

      describe 'but no "command" exists' do
        let(:yml) do
          <<-YML
            each:
              pattern: '.*'
          YML
        end

        it "returns errors" do
          subject.build_test_jobs.
            must_equal({ errors: '"each" block defined but no "command"'})
        end
      end

      it "creates jobs for all matching files replacing %{file}" do
        subject.build_test_jobs.must_equal true
        subject.test_jobs.map(&:command).
          must_equal ["bin/rake test test/features/funny_feature_test.rb"]
      end
    end

    describe 'when "raw" jobs exist' do
      let(:yml) do
        <<-YML
          each:
            pattern: 'no_match'
            command: "bin/rake test %{file}"
          javascript:
            command: "bin/rake test_javascript"
            before: "some before command"
            after: "some after command"
          selenium:
            command: "bin/rake test_selenium"
        YML
      end

      it "builds all specified jobs" do
        subject.build_test_jobs
        subject.test_jobs.map(&:command).
          must_equal ['bin/rake test_javascript', 'bin/rake test_selenium']
        subject.test_jobs.map(&:before).must_equal ['some before command', '']
        subject.test_jobs.map(&:after).must_equal ['some after command', '']
      end
    end
  end

  private

  def create_times(times, _test_run)
    times.each do |time|
      _test_run.test_jobs.build(
        started_at: time[:started_at], completed_at: time[:completed_at])
    end
  end
end
