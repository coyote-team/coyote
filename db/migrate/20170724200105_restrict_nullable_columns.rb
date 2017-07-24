class RestrictNullableColumns < ActiveRecord::Migration
  def change
    change_column_null :assignments, "user_id", false
    change_column_null :assignments, "image_id", false

    change_column_null :audits, "auditable_id", false
    change_column_null :audits, "auditable_type", false
    change_column_null :audits, "associated_id", false
    change_column_null :audits, "associated_type", false

    change_column_null  :descriptions, "status_id", false
    change_column_null  :descriptions, "image_id", false
    change_column_null  :descriptions, "metum_id", false
    change_column_null  :descriptions, "user_id", false

    change_column_null :images, "website_id", false
    change_column_null :images, "group_id", false
    change_column_null :images, "assignments_count", false
    change_column_null :images, "descriptions_count", false
    change_column_null :images, "priority", false
    change_column_null :images, "status_code", false

    change_column_null :meta, "title", null: false

    change_column_null :taggings, "tag_id", false
    change_column_null :taggings, "taggable_id", false
    change_column_null :taggings, "taggable_type", false
    change_column_null :taggings, "tagger_id", false
    change_column_null :taggings, "tagger_type", false

    change_column_null :tags, "name", false
    change_column_null :tags, "taggings_count", false
  end
end
