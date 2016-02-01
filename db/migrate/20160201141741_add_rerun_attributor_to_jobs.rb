class AddRerunAttributorToJobs < ActiveRecord::Migration
  def change
    add_column :test_jobs, :rerun, :boolean, null: false, default: false
  end
end
