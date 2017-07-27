class RenameImagesGroupIdToContextId < ActiveRecord::Migration
  def change
    rename_column :images, :group_id, :context_id
  end
end
