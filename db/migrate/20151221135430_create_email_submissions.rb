class CreateEmailSubmissions < ActiveRecord::Migration
  def change
    create_table :email_submissions do |t|
      t.string :email, null: false
    end
  end
end
