class AddOpenToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :open, :boolean, :default => 1
  end

  def self.down
    remove_column :tasks, :open
  end
end
