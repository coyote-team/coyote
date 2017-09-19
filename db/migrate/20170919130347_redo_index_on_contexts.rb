class RedoIndexOnContexts < ActiveRecord::Migration[5.1]
  def change
    remove_index :contexts, :organization_id
    add_index(:contexts,%i[organization_id title],unique: true)
  end
end
