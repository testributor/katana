class ChangeProjectsLimitTo10 < ActiveRecord::Migration
  def up
    change_column :users, :projects_limit, :integer, default: 10, null: false
    User.where("projects_limit < 10").update_all(projects_limit: 10)
  end

  def down
    change_column :users, :projects_limit, :integer, default: 1, null: false
  end
end
