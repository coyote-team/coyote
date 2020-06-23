class AddStatusToResources < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
    CREATE TYPE resource_status AS ENUM
    ('active', 'archived', 'deleted', 'not_found', 'unexpected_response')
    SQL

    add_column :resources, :status, :resource_status, index: true, null: false, default: 'active'
  end

  def down
    remove_column :resources, :status
    execute 'DROP TYPE resource_status'
  end
end
