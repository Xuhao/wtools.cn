class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
			t.encryptable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      t.string  :username
      t.string  :locale,     :default => 'zh-CN'                    # 语言
      t.string  :phone_num                                          # 电话号码
      t.boolean :admin,      :default => false,     :null => false  # 管理员
      t.string  :app_codes,  :default => 'job,plan'                 # 记录安装哪些应用
			t.integer :gold_count, :default => 10                         # 金币个数
      t.timestamps
    end

    add_index :users, :email, :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :users
  end
end
