class AddChunkIndexToTestJobs < ActiveRecord::Migration
  def change
    add_column :test_jobs, :chunk_index, :integer, null: false, default: 0
  end
end
