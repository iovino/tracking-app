class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.string :homepage
      t.string :ua_codes
      t.integer :user_id
      t.integer :status, :default => 2
      t.boolean :active, :default => true
      t.datetime :last_checked

      t.timestamps null: false
    end
  end
end
