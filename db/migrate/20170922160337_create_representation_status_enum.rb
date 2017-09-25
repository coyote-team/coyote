class CreateRepresentationStatusEnum < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
    CREATE TYPE representation_status AS ENUM 
    ('ready_to_review','approved','not_approved')
    SQL
  end

  def down
    execute 'DROP TYPE representation_status'
  end
end
