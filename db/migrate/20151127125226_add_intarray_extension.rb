class AddIntarrayExtension < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE EXTENSION IF NOT EXISTS intarray
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP EXTENSION IF EXISTS intarray
    SQL
  end
end
