class AddProjectIdToWorkerGroups < ActiveRecord::Migration
  def up
    add_column :worker_groups, :project_id, :integer

    WorkerGroup.reset_column_information

    Doorkeeper::Application.joins("LEFT JOIN projects ON owner_id = projects.id").
      where("projects.id IS NULL").delete_all

    WorkerGroup.joins(
      "LEFT JOIN oauth_applications "\
      "ON oauth_applications.id = worker_groups.oauth_application_id").
    where("oauth_applications.id IS NULL").delete_all

    WorkerGroup.joins(:oauth_application).find_each do |worker_group|
      worker_group.project_id = worker_group.oauth_application.owner_id
      worker_group.save!
    end

    change_column :worker_groups, :project_id, :integer, null: false
  end

  def down
    remove_column :worker_groups, :project_id
  end
end
