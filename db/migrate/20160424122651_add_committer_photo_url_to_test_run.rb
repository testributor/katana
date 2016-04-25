class AddCommitterPhotoUrlToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :commit_committer_photo_url, :string, default: '', null: false
  end
end
