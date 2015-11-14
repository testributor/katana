class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  attr_encrypted_options.merge!(key: ENV['ENCRYPTED_TOKEN_SECRET'],
    mode: :per_attribute_iv_and_salt)
  attr_encryptor :github_access_token

  belongs_to :invited_by, class_name: "Project"
  has_many :projects # on which this user is an owner
  has_and_belongs_to_many :participating_projects, class_name: "Project"
  has_many :tracked_branches, through: :participating_projects
  has_many :test_runs, through: :tracked_branches
  has_one :project_wizard


  GITHUB_REQUIRED_SCOPES = %w(user:email repo)

  def can_create_new_project?
    projects_limit >= Project.where(user_id: id).count + 1
  end

  def github_client
    if github_access_token.present?
      client = Octokit::Client.new(access_token: github_access_token)

      (client.scopes & GITHUB_REQUIRED_SCOPES).size == 2 ? client : nil
    end
  rescue Octokit::Unauthorized
    return
  end
end
