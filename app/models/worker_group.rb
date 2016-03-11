class WorkerGroup < ActiveRecord::Base
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application'
  belongs_to :project

  attr_encryptor :ssh_key_private, key: ENV['ENCRYPTED_TOKEN_SECRET'],
    mode: :per_attribute_iv_and_salt, unless: Rails.env.test?

  validates :project, presence: true
  validates :friendly_name, presence: true

  before_validation :generate_ssh_keys, on: :create,
    if: ->{ ssh_key_private.blank? }
  before_create :set_ssh_key_in_repo, unless: ->{ Rails.env.test? }
  before_save :rename_ssh_key_in_repo,
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
    case project.repository_provider
    when 'github'
      begin
        deploy_key = project.user.github_client.add_deploy_key(
          project.repository_id,
          friendly_name,
          ssh_key_public,
          read_only: true
        )
      rescue Octokit::UnprocessableEntity => ex
        if ex.errors.count {|e| e[:message] =~ /key is already in use/} > 0
          return
        else
          raise ex
        end
      end

      self.ssh_key_provider_reference_id = deploy_key.id
    else
      raise "Don't know how to set the SSH key."
    end
  end

  def generate_ssh_keys
    ssh_key = SSHKey.generate(bits: 4096, comment: project.user.email)
    self.ssh_key_private = ssh_key.private_key
    self.ssh_key_public = ssh_key.ssh_public_key
  end

  def remove_ssh_key_from_repo
    # This API call will return a boolean upon success or failure to remove
    # the deploy key. A false return value will not stop the record destruction.
    project.user.github_client.remove_deploy_key(
      project.repository_id,
      ssh_key_provider_reference_id
    )
  end

  def rename_ssh_key_in_repo
    remove_ssh_key_from_repo
    set_ssh_key_in_repo
  end
end
