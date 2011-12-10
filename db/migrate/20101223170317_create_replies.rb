class CreateReplies < ActiveRecord::Migration
  def self.up
    create_table :replies do |t|
      t.integer :user_id,     :null => false
      t.integer :feedback_id, :null => false
      t.integer :reply_id
      t.string  :content,     :null => false
      t.timestamps
    end
    add_index(:replies, :feedback_id)
  end

  def self.down
    drop_table :replies
  end
end
