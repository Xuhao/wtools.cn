class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string    :type,                   :null => false
      t.integer   :user_id,                :null => false
      t.integer   :style_id
      t.integer   :category_id,            :default => 1
      t.string    :name,                   :null => false
      t.string    :description
      #整个任务所需时间总量
      t.integer   :time_num,               :null => false
      #时间单位(天/周/月/季/年)
      t.string    :time_type,              :null => false
      t.date      :begin_at,               :null => false
      t.date      :end_at,                   :null => false
      t.date      :last_show_at
      t.boolean   :log_able,               :null => false, :default => false
      t.string    :aspire_word
      t.boolean   :show_control,                            :default => false
      t.string    :show_site
      t.boolean   :sms_alert,              :null => false, :default => false
      t.boolean   :email_alert,            :null => false, :default => false
      t.integer   :delay_for_alert
      t.integer   :completed_ratio,                         :default => 0
      t.integer   :should_completed_ratio,                 :default => 0
      t.string    :status,                 :null => false,  :default => 'normal'
      t.timestamps
    end

    add_index :tasks, :user_id
    add_index :tasks, :name
    add_index :tasks, :type
    add_index :tasks, :status
  end

  def self.down
    drop_table :tasks
  end
end
