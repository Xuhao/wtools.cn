class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :title,       :null => false
      t.text   :content,       :null => false
      t.string :target,      :null => false
      t.datetime :created_at
    end
		add_index :messages, :title
		add_index :messages, :target
  end

  def self.down
    drop_table :messages
  end
end
