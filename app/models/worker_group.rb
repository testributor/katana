class WorkerGroup < ActiveRecord::Base
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application'
  belongs_to :project

  attr_encryptor :ssh_key_private, key: ENV['ENCRYPTED_TOKEN_SECRET'],
    mode: :per_attribute_iv_and_salt, unless: Rails.env.test?

  validates :project, presence: true
  validates :friendly_name, presence: true
  validates :friendly_name, uniqueness: { scope: :project }
  validates :ssh_key_private, presence: true
  validate :valid_keys

  before_validation :generate_ssh_keys, on: :create,
    if: ->{ project.repository_provider != "bare_repo" && ssh_key_private.blank? }

  before_create :set_ssh_key_in_repo,
    if: ->{ project.repository_provider != "bare_repo" && !Rails.env.test? }

  # We never ask for the public key, only the private. We already know that
  # private is set and valid (check validations) so we can create the public
  # key before we save the record.
  before_save :set_public_key,
    if: ->{ project.repository_provider == "bare_repo" && ssh_key_private.present? }

  after_create :create_oauth_application
  before_update :rename_ssh_key_in_repo,
    if: ->{ friendly_name_changed? && !Rails.env.test? }
  after_destroy :remove_ssh_key_from_repo,
    if: ->{ ssh_key_provider_reference_id_was }

  def reset_ssh_key!
    remove_ssh_key_from_repo
    generate_ssh_keys
    set_ssh_key_in_repo

    save!
  end

  private

  def create_oauth_application
    oauth_application = project.oauth_applications.create!(
      name: project.repository_id || project.repository_slug ||
        project.repository_name,
      redirect_uri: Katana::Application::HEROKU_URL)
    save!
  end

  def set_ssh_key_in_repo
    deploy_key = repository_manager.set_deploy_key(ssh_key_public,
      { friendly_name: friendly_name, read_only: true })

    self.ssh_key_provider_reference_id =
      deploy_key.try(:id) || deploy_key.try(:pk)
  end

  # This method uses the private key to generate the public. It should be run
  # only after making sure (through validations) that the private key exists
  # and that is valid, so it makes no effort to check for validity.
  def set_public_key
    if ssh_key_private.present?
      self.ssh_key_public =
        SSHKey.new(ssh_key_private, comment: project.user.email).ssh_public_key
    end
  end

  def generate_ssh_keys
    return nil if project.repository_provider == "bare_repo"

    ssh_key = SSHKey.generate(bits: 4096, comment: project.user.email)
    self.ssh_key_private = ssh_key.private_key
    self.ssh_key_public = ssh_key.ssh_public_key
  end

  def valid_keys
    return nil if ssh_key_private.blank?

    begin
      # Consider asking the user for the passphrase, when we enable
      # HTTPS everywhere, instead of assuming there is no passphrase.
      ssh_key = SSHKey.new(ssh_key_private, passphrase: '')
    rescue OpenSSL::PKey::DSAError
      errors.add(:ssh_key_private, :invalid)
    end
  end

  def remove_ssh_key_from_repo
    repository_manager.remove_deploy_key(ssh_key_provider_reference_id)
  end

  def rename_ssh_key_in_repo
    remove_ssh_key_from_repo
    set_ssh_key_in_repo
  end

  def repository_manager
    @repository_manager ||= RepositoryManager.new(project)
  end
end
