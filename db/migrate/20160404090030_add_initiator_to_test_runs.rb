class AddInitiatorToTestRuns < ActiveRecord::Migration
  def change
    add_column :test_runs, :initiator_id, :integer, index: true
  end
end
