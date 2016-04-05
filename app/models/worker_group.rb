class WorkerGroup < ActiveRecord::Base
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application'
  belongs_to :project

  attr_encryptor :ssh_key_private, key: ENV['ENCRYPTED_TOKEN_SECRET'],
    mode: :per_attribute_iv_and_salt, unless: Rails.env.test?

  validates :project, presence: true
  validates :friendly_name, presence: true
  validates :friendly_name, uniqueness: { scope: :project }
  validate :valid_keys

  before_validation :generate_ssh_keys, on: :create
  before_create :set_ssh_key_in_repo, unless: ->{ Rails.env.test? }
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

  def set_ssh_key_in_repo
    deploy_key = repository_manager.set_deploy_key(ssh_key_public,
      { friendly_name: friendly_name, read_only: true })

    self.ssh_key_provider_reference_id =
      deploy_key.try(:id) || deploy_key.try(:pk)
  end

  def generate_ssh_keys
    if ssh_key_private.blank? && ssh_key_public.blank?
      ssh_key = SSHKey.generate(bits: 4096, comment: project.user.email)
      self.ssh_key_private = ssh_key.private_key
      self.ssh_key_public = ssh_key.ssh_public_key
    elsif ssh_key_public.blank?
      begin
        ssh_key = SSHKey.new(ssh_key_private, comment: project.user.email)
        self.ssh_key_public = ssh_key.ssh_public_key
      rescue OpenSSL::PKey::DSAError
        nil # Leave public key empty if private is invalid
      end
    end
  end

  def valid_keys
    return nil if ssh_key_private.blank?

    begin
      ssh_key = SSHKey.new(ssh_key_private)
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
