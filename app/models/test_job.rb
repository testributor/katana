class TestJob < ActiveRecord::Base
  has_many :test_job_files, dependent: :delete_all
  belongs_to :tracked_branch
  belongs_to :user
  belongs_to :tracked_branch
  has_one :project, through: :tracked_branch

  delegate :completed_at, to: :last_file_run, allow_nil: true

  scope :pending, -> { where(status: TestStatus::PENDING) }
  scope :running, -> { where(status: TestStatus::RUNNING) }
  scope :complete, -> { where(status: TestStatus::COMPLETE) }
  scope :cancelled, -> { where(status: TestStatus::CANCELLED) }

  def total_running_time
    completed_at_times = test_job_files.order("completed_at ASC").
      pluck(:completed_at)
    started_at_times = test_job_files.order("started_at ASC").
      pluck(:started_at)

    if completed_at_times.length == completed_at_times.compact.length
      time = completed_at_times.last - started_at_times.first
    elsif time_first_job_started = started_at_times.compact.first
      time = Time.now - time_first_job_started
    end

    time.round if time
  end

  def status_text
    TestStatus.new(status, failed?).text
  end

  def css_class
    TestStatus.new(status, failed?).css_class
  end

  def build_test_job_files
    test_file_names.map { |file_name| test_job_files.build(file_name: file_name) }
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
    test_job_files.order(:completed_at).last
  end

  def github_client
    tracked_branch.project.user.github_client
  end

  def failed?
    test_job_files.any? { |file| file.failed? }
  end
end
