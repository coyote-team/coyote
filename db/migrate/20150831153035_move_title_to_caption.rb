class MoveTitleToCaption < ActiveRecord::Migration
  def change
    Description.all.each do |d|
      d.metum_id = 2
      d.save!
    end
  end
end
