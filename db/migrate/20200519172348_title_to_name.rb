class TitleToName < ActiveRecord::Migration[6.0]
  def change
    # Drop unused legacy tables
    %i[descriptions images statuses taggings tags ].each do |table|
      drop_table table
    end

    # Rename title `columns` to `name`
    %i[meta organizations resource_groups resources].each do |table|
      rename_column table, :title, :name
    end

    rename_column :licenses, :title, :description
  end
end
