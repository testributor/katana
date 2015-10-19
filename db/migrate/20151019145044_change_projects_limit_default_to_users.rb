class ChangeProjectsLimitDefaultToUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :projects_limit, 1
  end
end
