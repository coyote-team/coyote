class CreateRepresentationRejections < ActiveRecord::Migration[6.0]
  def change
    create_table :representation_rejections do |t|
      t.belongs_to :representation, foreign_key: true, index: true
      t.belongs_to :user, foreign_key: true, index: true
      t.text :reason, null: false
      t.timestamps
    end

    remove_column :representations, :rejection_reason
  end
end
