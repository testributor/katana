class ChangeProjectsLimitDefaultToUsers < ActiveRecord::Migration
  def up
    change_column_default :users, :projects_limit, 1
  end

  def down
    change_column_default :users, :projects_limit, 0
  end
end
