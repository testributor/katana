class CreateWorkerGroups < ActiveRecord::Migration
  def up
    create_table :worker_groups do |t|
      t.belongs_to :oauth_application, index: true, null: false
      t.string :friendly_name
      t.text :encrypted_ssh_key_private
      t.string :encrypted_ssh_key_private_salt
      t.string :encrypted_ssh_key_private_iv
      t.text :ssh_key_public
      t.integer :ssh_key_provider_reference_id
    end

    Project.includes(:oauth_applications).each do |project|
      project.oauth_applications.each do |oauth_application|
        WorkerGroup.create!(oauth_application: oauth_application,
          friendly_name: "#{project.name} Worker Group #{project.oauth_applications.size}")
      end
    end
  end

  def down
    drop_table :worker_groups
  end
end
