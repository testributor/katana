class TestRun < ActiveRecord::Base
  JOBS_YML_PATH = "testributor.yml"

  has_many :test_jobs, dependent: :delete_all
  belongs_to :tracked_branch
  belongs_to :user
  belongs_to :tracked_branch
  has_one :project, through: :tracked_branch

  delegate :started_at, :completed_at, to: :last_file_run, allow_nil: true

  scope :pending, -> { where(status: TestStatus::PENDING) }
  scope :running, -> { where(status: TestStatus::RUNNING) }
  scope :complete, -> { where(status: TestStatus::COMPLETE) }
  scope :cancelled, -> { where(status: TestStatus::CANCELLED) }

  def total_running_time
    completed_at_times = test_jobs.map(&:completed_at).compact.sort
    started_at_times = test_jobs.map(&:started_at).sort

    return if completed_at_times.blank? || started_at_times.blank?

    if completed_at_times.length == started_at_times.length
      time = completed_at_times.last - started_at_times.first
    elsif time_first_job_started = started_at_times.compact.first
      time = Time.now - time_first_job_started
    end

    time.round if time
  end

  def status
    TestStatus.new(read_attribute(:status), failed?)
  end

  def build_test_jobs
    test_file_names.map { |file_name| test_jobs.build(file_name: file_name) }
  end

  # Returns the content of JOBS_YML_PATH file. The file can either be defined
  # in Project's files (project_files association) or it can be checked in the
  # git repository. If defined both ways the repo version wins to let the users
  # use a customized file in specific branches (e.g. if they don't want to run
  # all tests on some feature branch they can commit this file to override the
  # global project configuration).
  def jobs_yml
    file = nil

    if github_client.present?
      repo = tracked_branch.project.repository_id
      file = 
        begin
          file =
            github_client.contents(repo, path: JOBS_YML_PATH, ref: commit_sha)

          Base64.decode64(file.content)
        rescue Octokit::NotFound
          nil
        end
    end

    if file.blank?
      file =
        project.project_files.where(path: JOBS_YML_PATH).first.try(:contents)
    end

    file
  end

  # This method returns all test filenames
  # for a given TestJob from github.
  def test_file_names
    repo = tracked_branch.project.repository_id
    github_client.tree(repo, commit_sha, recursive: true)[:tree].map(&:path).
      select { |path| path.match(/_test\.rb/) }
  end

  private

  def last_file_run
    test_jobs.sort_by(&:completed_at).last
  end

  def github_client
    tracked_branch.project.user.github_client
  end

  def failed?
    test_jobs.any? { |file| file.failed? }
  end
end
