class CreateIps < ActiveRecord::Migration
  def self.up
    create_table :ips do |t|
      t.string   :ip
			t.datetime :created_at
    end
		add_index :ips, :ip
		add_index :ips, :created_at
  end

  def self.down
    drop_table :ips
  end
end
