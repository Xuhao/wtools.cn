class CreateTaskLogs < ActiveRecord::Migration
  def self.up
    create_table :task_logs do |t|
      t.integer :task_id,    :null => false
      t.boolean :done,                       :default => 0
      t.date    :done_at
      t.integer :ratio,                      :default => 0
      t.string  :content
      t.integer :evaluation

      t.timestamps
    end

    add_index :task_logs,:task_id
  end

  def self.down
    drop_table :task_logs
  end
end
