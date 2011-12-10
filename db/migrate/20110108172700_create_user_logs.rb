class CreateUserLogs < ActiveRecord::Migration
  def self.up
    create_table :user_logs do |t|
      t.integer  :user_id,     :null => false
			t.string   :log_type,    :null => false
			t.integer  :relation_id
			t.integer  :gold_count
      t.string   :content,     :null => false
      t.string   :query_string
      t.datetime :created_at,  :null => false
    end
		add_index :user_logs, :user_id
  end

  def self.down
    drop_table :user_logs
  end
end
