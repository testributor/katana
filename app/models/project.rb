class Project < ActiveRecord::Base
  attr_accessor :about_to_be_destroyed

  include Models::RedisLiveUpdates

  ACTIVE_WORKER_THRESHOLD_SECONDS = 20

  devise :database_authenticatable

  belongs_to :user # this is the owner of the project
  belongs_to :docker_image # This is the base image

  has_one :docker_image_selection

  has_many :tracked_branches, dependent: :destroy, inverse_of: :project
  has_many :test_runs
  has_many :test_jobs, through: :test_runs
  has_many :project_participations, dependent: :destroy
  has_many :members, through: :project_participations, class_name: "User",
    source: :user
  has_many :user_invitations, dependent: :destroy
  has_many :invited_users, through: :user_invitations, class_name: 'User',
    source: :user
  has_many :project_files, dependent: :destroy
  has_many :oauth_applications, class_name: 'Doorkeeper::Application',
    as: :owner, dependent: :destroy
  has_many :worker_groups, dependent: :destroy
  has_many :technology_selections, dependent: :destroy
  has_many :technologies, through: :technology_selections

  validates :name, :user, presence: true
  validates :name, uniqueness: { scope: [:user, :repository_provider, :repository_owner] }
  validates :repository_url, presence: true,
    if: ->{ repository_provider == 'bare_repo' }
  validate :check_user_limit, if: :user_id_changed?
  validate :valid_custom_docker_compose_yml, if: ->{
    custom_docker_compose_yml.present?
  }

  before_create :set_secure_random
  # Set this flag to true in order to destroy testributor.yml and
  # build_commands.sh which can't be deleted otherwise.
  # Use prepend: true to guarantee that it is called before childrens'
  # destroy methods.
  before_destroy :set_about_to_be_destroyed, prepend: true
  # TODO: Run cron job to ensure all owners are also participants
  after_create :add_owner_to_participants
  after_create :create_build_commands_file

  attr_accessor :fork

  scope :bitbucket, ->{ where(repository_provider: 'bitbucket') }
  scope :github, ->{ where(repository_provider: 'github') }
  scope :non_private, ->{ where(is_private: false) }
  scope :bare_repo, ->{ where(repository_provider: 'bare_repo') }

  def to_param
    "#{id}-#{name.gsub(/[^a-z0-9]+/i, '-').downcase}"
  end

  def workers_redis_key
    "project_#{id}_workers"
  end

  # Updates the project's set of workers with only the active
  # and returns the list of active worker uuids
  # Only this method should be called to find the active workers since directly
  # quering for the key in Redis will not clean up the list
  # http://stackoverflow.com/a/8833058
  def update_active_workers
    redis = Katana::Application.redis
    key = workers_redis_key
    active = redis.sort(key, by: 'nosort', get: '*').compact
    redis.multi do
      redis.del(key)
      redis.sadd(key, active) if active.any?
    end

    active
  end
  alias :active_workers :update_active_workers

  def owner_and_name
    result = ""
    result << "#{repository_owner}/" if repository_owner.present?
    result << repository_name

    result
  end

  def bare_repo?
    repository_provider == "bare_repo"
  end

  # @param private_ssh_key [String] it is used as the private ssh key when it
  # exists
  # TODO: Remove the bang from method name
  def create_oauth_application!(ssh_key_private=nil, friendly_name=nil)
    errors = nil
    WorkerGroup.transaction do
      oauth_application = oauth_applications.new(
        name: repository_id || repository_slug || repository_name,
        redirect_uri: Katana::Application::HEROKU_URL
      )

      unless oauth_application.save
        errors = oauth_application.errors.full_messages.to_sentence
        # Silently rollback
        # http://api.rubyonrails.org/classes/ActiveRecord/Rollback.html
        raise ActiveRecord::Rollback, "Validation errors!"
      end

      worker_group = worker_groups.new(oauth_application: oauth_application,
        ssh_key_private: ssh_key_private,
        friendly_name: friendly_name || "#{name} Worker Group #{oauth_applications.count}")

      unless worker_group.save
        errors = worker_group.errors.full_messages.to_sentence
        # Silently rollback
        # http://api.rubyonrails.org/classes/ActiveRecord/Rollback.html
        raise ActiveRecord::Rollback, "Validation errors!"
      end
    end

    errors
  end

  def destroy_oauth_application!(oauth_application_id)
    oauth_application = oauth_applications.find(oauth_application_id)
    WorkerGroup.transaction do
      worker_groups.where(oauth_application_id: oauth_application_id).
        each(&:destroy!)
      oauth_application.destroy!
    end
  end

  def generate_docker_compose_yaml(oauth_app_id)
    DockerComposeBuilder.new(self).docker_compose_yml(oauth_app_id)
  end

  # For now we simply create the file based on a template. In the future
  # we might want to "look" at the code to decide about the code, testing
  # framework etc to be able to build a more sophisticated yml file.
  def create_testributor_yml_file!
    testributor_yml_file =
      project_files.find_or_initialize_by(path: ProjectFile::JOBS_YML_PATH)
    testributor_yml_file.contents = File.read(
      File.join(Rails.root, 'app', 'file_templates', ProjectFile::JOBS_YML_PATH))

    testributor_yml_file.save!
  end

  def is_public?
    !is_private
  end

  def testributor_yml_contents
    project_files.where(path: ProjectFile::JOBS_YML_PATH).first.try(:contents)
  end

  def custom_docker_compose_yml_as_hash
    result = SafeYAML.load(custom_docker_compose_yml.to_s)

    result.is_a?(Hash) ? result : false
  end

  private

  def set_about_to_be_destroyed
    self.about_to_be_destroyed = true
  end

  # Don't let a project be assigned to a user if projects limit
  # has been reached
  def check_user_limit
    if user && !user.can_create_new_project?
      errors.add(:base, :project_limit_reached)
    end
  end

  # TODO: Add tests for this
  def add_owner_to_participants
    self.members << self.user
  end

  def create_build_commands_file
    self.project_files.create!(path: ProjectFile::BUILD_COMMANDS_PATH)
  end

  def set_secure_random
    self.secure_random = SecureRandom.hex

    #in case a secure random exists
    while Project.find_by_secure_random(self.secure_random)
      self.secure_random = SecureRandom.hex
    end
  end

  def valid_custom_docker_compose_yml
    begin
      result = custom_docker_compose_yml_as_hash

      unless result
        errors.add(:custom_docker_compose_yml, :not_compatible_format)
      end
    rescue Psych::SyntaxError
      errors.add(:custom_docker_compose_yml, :syntax_error)
    end
  end
end
