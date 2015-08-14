class CreateTestJobFiles < ActiveRecord::Migration
  def change
    create_table :test_job_files do |t|
      t.integer :test_job_id
      t.string :file_name, null: false, default: ''
      t.text :result, null: false, default: ''
      t.integer :status, null: false, default: 0
      t.integer :test_errors, null: false, default: 0
      t.integer :failures, null: false, default: 0
      t.integer :count, null: false, default: 0
      t.integer :assertions, null: false, default: 0
      t.integer :skips, null: false, default: 0
      t.datetime :started_at
      t.datetime :completed_at
      t.text :result, null: false, default: ''
      t.timestamps
    end
  end
end
