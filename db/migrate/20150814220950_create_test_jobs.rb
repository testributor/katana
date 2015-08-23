class CreateTestJobs < ActiveRecord::Migration
  def change
    create_table :test_jobs do |t|
      t.integer :user_id, index: true
      t.string :git_ref
      t.integer :status, null: false, default: 0
      t.integer :test_job_file_id, null: false, default: 0, index: true
      t.timestamps
    end
  end
end
