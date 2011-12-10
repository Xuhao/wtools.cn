class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string  :type ,      :null => false
      t.string  :name ,      :null => false
      t.text    :answer,     :null => false
      t.integer :hits,                     :default => 0

      t.timestamps
    end
    add_index :questions, :type
    add_index :questions, :name
  end

  def self.down
    drop_table :questions
  end
end
