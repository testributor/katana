class AddShaHistoryToTestRuns < ActiveRecord::Migration
  def change
    add_column :test_runs, :sha_history, :text, array: true, null: false,
      default: []
  end
end
