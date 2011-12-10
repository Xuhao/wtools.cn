class AddHasReadMessageIdsColumnsToUser < ActiveRecord::Migration
  def self.up
		add_column :users, :has_read_message_ids, :string
  end

  def self.down
		remove_column :users, :has_read_message_ids
  end
end
