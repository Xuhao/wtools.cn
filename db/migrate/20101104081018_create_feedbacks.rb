class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.integer  :user_id,      :null => false
      t.string   :type,         :null => false
      t.string   :title,        :null => false
      t.text     :content,      :null => false
      t.integer  :replies_count,                :default => 0
      t.integer  :agree_num,                    :default => 0
      t.integer  :against_num,                  :default => 0
      t.timestamps
    end
    add_index :feedbacks,:user_id
    add_index :feedbacks,:type

  end

  def self.down
    drop_table :feedbacks
  end
end
