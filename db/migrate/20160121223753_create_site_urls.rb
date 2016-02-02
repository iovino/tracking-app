class CreateSiteUrls < ActiveRecord::Migration
  def change
    create_table :site_urls do |t|
      t.string :url
      t.integer :site_id

      t.timestamps null: false
    end
  end
end
