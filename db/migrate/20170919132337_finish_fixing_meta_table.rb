class FinishFixingMetaTable < ActiveRecord::Migration[5.1]
  def change
    if Rails.env.production?
      Metum.update_all(organization_id: 2) # MCA Chicago's ID at the time of this migration's creation
    else
      Metum.update_all(organization_id: Organization.pluck(:id).first) if Metum.any?
    end

    change_column_null :meta, :organization_id, false

    add_index :meta, %i[organization_id title], unique: true
  end
end
