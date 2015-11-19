class Add < ActiveRecord::Migration
  def change
    add_column :projects_users, :id, :primary_key
    add_column :projects_users, :created_at, :datetime
    add_column :projects_users, :updated_at, :datetime
  end
end
