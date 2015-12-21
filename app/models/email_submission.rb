class EmailSubmission < ActiveRecord::Base
  validates :email, presence: true
  validates_with EmailValidator
end
