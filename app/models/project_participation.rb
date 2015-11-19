class ProjectParticipation < ActiveRecord::Base
  self.table_name = :projects_users

  belongs_to :project
  belongs_to :user

end
