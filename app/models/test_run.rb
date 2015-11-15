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

  # Example yml file:
  # each:
  #   pattern: 'test/*/**_test.rb'
  #   command: 'bin/rake test %{file}'
  #   before: 'some_command'
  # javascript:
  #   command: 'bin/rake test_javascript'
  #   after: "some_cleanup_command"
  #
  # Return value meaning:
  #   - Hash with errors key: syntax error in yml pattern missing or other
  #   - true: jobs built successfully
  #   TODO: Remove errors hash from this method and add it to project_file
  #   as a validation
  def build_test_jobs
    yml_contents = jobs_yml
    return { errors: "No testributor.yml file found" } unless yml_contents

    begin
      jobs_description = YAML.load(yml_contents)
    rescue Psych::SyntaxError
      return { errors: "yml syntax error" }
    end

    if (each_description = jobs_description.delete("each"))
      pattern = each_description["pattern"]
      command = each_description["command"]
      before = each_description["before"].to_s
      after = each_description["after"].to_s

      return { errors: '"each" block defined but no "pattern"' } unless pattern
      return { errors: '"each" block defined but no "command"' } unless command

      file_names = project_file_names
      file_names.select{|f| f.match(pattern)}.each do |f|
        test_jobs.build(
          command: command.gsub(/%{file}/, f), before: before, after: after)
      end
    end

    jobs_description.each do |job_name, description|
      command = description["command"]
      before = description["before"].to_s
      after = description["after"].to_s

      return { errors: "#{job_name} is missing \"command\" key" } unless command

      test_jobs.build(command: command, before: before, after: after)
    end

    true
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

  # This method returns all filenames for this repo and ref from github.
  # TODO: Github limit is something like 1000 files per request.
  # Refactor this method so that it always returns all filenames no matter
  # how many (or find some better solution).
  def project_file_names
    repo = tracked_branch.project.repository_id
    github_client.tree(repo, commit_sha, recursive: true)[:tree].map(&:path)
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
