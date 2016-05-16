class BareRepositoryManager::TestRunSetupJobTest < ActiveJob::TestCase
  describe "perform" do
    let(:project) { FactoryGirl.create(:project) }
    let(:_test_run) { TestRun.create!(commit_sha: "123", project: project) }
    let(:data) do
      { subject: "Taking advantage of a serious exploit",
        author_name: "Kevin Mitnick",
        author_email: "kevin@the_rock.com",
        commiter_name: "someone else",
        commiter_email: "someone_else@microsoft.com",
        sha_history: ["1234", "2345", "3456"],
        committer_date_unix: Time.new(2016, 01, 01, 00, 00, 00).to_i.to_s,
        jobs: [
          { job_name: "First job", command: "bin/rake test first",
            before: "before command", after: "after command" },
          { job_name: "Second job", command: "bin/rake test second",
            before: "before command 2", after: "after command 2" },
        ]
      }.to_json
    end

    subject do
      BareRepositoryManager::TestRunSetupJob.new
    end

    before do
      # Save before the tests to run any on-creation Broadcaster
      # events now. We count how many time they run on update and we don't want
      # our values to count the creation hooks.
      _test_run
    end

    describe "when the data is not valid JSON" do
      let(:data) { "this is some invalid json: " }
      it "assigns an error to the TestRun and updates the status to ERROR" do
        subject.perform(_test_run.id, data)
        _test_run.reload.setup_error.must_equal(
          "Could not parse the worker's setup data")
        _test_run.status.code.must_equal TestStatus::ERROR
      end
    end

    describe "when data contains and error" do
      let(:data) { { "error" => "some error" }.to_json }
      it "assigns the error to the TestRun and updates the status to ERROR" do
        subject.perform(_test_run.id, data)
        _test_run.reload.setup_error.must_equal "some error"
        _test_run.status.code.must_equal TestStatus::ERROR
      end
    end

    it "assigns the meta information to the TestRun" do
      subject.perform(_test_run.id, data)
      _test_run.reload.commit_message.must_equal "Taking advantage of a serious exploit"
      _test_run.commit_author_email.must_equal "kevin@the_rock.com"
      _test_run.commit_author_name.must_equal "Kevin Mitnick"
      _test_run.commit_committer_email.must_equal "someone_else@microsoft.com"
      _test_run.commit_committer_name.must_equal "someone else"
      _test_run.commit_timestamp.must_equal Time.new(2016, 01, 01, 00, 00, 00)
    end

    it "assigns chunk indices to TestJobs" do
      subject.perform(_test_run.id, data)
      _test_run.reload.test_jobs.map(&:chunk_index).must_equal [0, 1]
    end

    it "broadcasts an update on TestRun" do
      Broadcaster.expects(:publish).with(
        _test_run.redis_live_update_resource_key, instance_of(Hash)).once
      subject.perform(_test_run.id, data)
    end
  end
end
