class UserInvitation < ActiveRecord::Base
  TOKEN_SIZE = 30
  # If no uniq token is found after 10 tries, something is wrong.
  UNIQUE_TOKEN_TRIES_LIMIT = 10

  belongs_to :project
  belongs_to :user

  validates :project, :token, :email, presence: true
  validates :email, uniqueness: { scope: :project_id }
  validate :user_is_not_already_member

  before_validation :create_token, if: ->{ token.blank? }
  after_create :queue_email

  scope :pending, ->{ where(accepted_at: nil) }

  def pending?
    accepted_at.nil?
  end

  def accept!(user)
    self.user = user
    self.accepted_at = DateTime.current
    self.save!
    self.project.members << user
  end

  def queue_email
    UserInvitationMailer.new_invitation(id).deliver_later
  end

  private

  def create_token
    return false if token.present?

    unique_token_found = false
    tries = 0
    # Race conditions apply but they are very unlikely to happen
    # (E.g. we find a unique token but it is not unique when we try to save)
    while !unique_token_found && tries <= UNIQUE_TOKEN_TRIES_LIMIT
      tries += 1
      self.token = SecureRandom.hex(TOKEN_SIZE)
      unique_token_found = true if self.class.where(token: self.token).count == 0
    end
  end

  def user_is_not_already_member
    if user && project && project.members.include?(user)
      errors.add(:email, "User is already a member of this project")
    end
  end
end
