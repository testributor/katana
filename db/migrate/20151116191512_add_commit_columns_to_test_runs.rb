class AddCommitColumnsToTestRuns < ActiveRecord::Migration
  def change
    change_table :test_runs do |t|
      t.string :commit_message
      t.datetime :commit_timestamp
      t.string :commit_url
      t.string :commit_author_name
      t.string :commit_author_email
      t.string :commit_author_username
      t.string :commit_committer_name
      t.string :commit_committer_email
      t.string :commit_committer_username
    end
  end
end
