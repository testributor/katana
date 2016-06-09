class ChangeProjectsWebhookIdColumnFromIntegerToString < ActiveRecord::Migration
  def up
    change_column :projects, :webhook_id, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
