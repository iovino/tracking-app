class CreateSiteErrors < ActiveRecord::Migration
  def change
    create_table :site_errors do |t|
      t.text :message
      t.integer :site_id

      t.timestamps null: false
    end
  end
end
