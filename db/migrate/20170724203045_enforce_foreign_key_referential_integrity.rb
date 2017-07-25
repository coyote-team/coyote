class EnforceForeignKeyReferentialIntegrity < ActiveRecord::Migration
  def up
    remove_foreign_key "assignments", "images"
    add_foreign_key "assignments", "images", :on_delete => :cascade, :on_update => :cascade

    remove_foreign_key "assignments", "users"
    add_foreign_key "assignments", "users", :on_delete => :cascade, :on_update => :cascade

    remove_foreign_key "descriptions", "images"
    add_foreign_key "descriptions", "images", :on_delete => :cascade, :on_update => :cascade

    remove_foreign_key "descriptions", "meta"
    add_foreign_key "descriptions", "meta", :on_delete => :cascade, :on_update => :cascade

    remove_foreign_key "descriptions", "statuses"
    add_foreign_key "descriptions", "statuses", :on_delete => :cascade, :on_update => :cascade

    remove_foreign_key "descriptions", "users"
    add_foreign_key "descriptions", "users", :on_delete => :cascade, :on_update => :cascade

    remove_foreign_key "images", "groups"
    add_foreign_key "images", "groups", :on_delete => :cascade, :on_update => :cascade

    remove_foreign_key "images", "websites"
    add_foreign_key "images", "websites", :on_delete => :cascade, :on_update => :cascade
  end
end
