class ConvertPageUrlsToPgArray < ActiveRecord::Migration
  def up
    execute <<~SQL
    ALTER TABLE "images" 
    ALTER COLUMN "page_urls" TYPE character varying[]
    USING page_urls::character varying[];

    ALTER TABLE "images" 
    ALTER COLUMN "page_urls" SET DEFAULT array[]::varchar[];

    ALTER TABLE "images" 
    ALTER COLUMN "page_urls" SET NOT NULL;
    SQL
  end

  def down
    change_column :images, :page_urls, :text
  end
end
