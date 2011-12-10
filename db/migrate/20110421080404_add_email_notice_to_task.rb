class AddEmailNoticeToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :email_notice, :boolean, :default => 1
  end

  def self.down
    remove_column :tasks, :email_notice
  end
end
