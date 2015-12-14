class RemoveLastUsedAtFromDoorkeeperAccessTokens < ActiveRecord::Migration
  def up
    remove_column :oauth_access_tokens, :last_used_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
