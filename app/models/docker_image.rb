class DockerImage < ActiveRecord::Base
  # Disable inheritance
  self.inheritance_column = nil

  scope :languages, -> { where(type: 'language') }
  scope :technologies, -> { where(type: 'technology') }

  validates :standardized_name, presence: true
end
