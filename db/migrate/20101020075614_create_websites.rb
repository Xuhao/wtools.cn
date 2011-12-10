class CreateWebsites < ActiveRecord::Migration
  def self.up
    create_table :websites do |t|
      t.references :user
      t.string     :name
      t.string     :url,        :null => false
      t.string     :description
      t.timestamps
    end
    add_index :websites, :user_id
    add_index :websites, :url
  end

  def self.down
    drop_table :websites
  end
end
