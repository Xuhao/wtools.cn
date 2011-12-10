class Message < ActiveRecord::Base
	default_scope order('created_at DESC')
	validates :title, :presence => true
  validates :content, :presence => true
  validates :target, :presence => true

	class << self
		
		# => 用户所属的系统信息
		def user_messages(user)
			if user.admin
				all
			else
				where("target = 'all' or target like ',%#{user.id}%,'")
			end
		end

		# 某用户未读信息个数
		def not_read_count(user)
			if user.has_read_message_ids_arr.empty?
				count(:conditions => "target = 'all' or target like ',%#{user.id}%,'")
			else
				count(:conditions => "(target = 'all' or target like ',%#{user.id}%,') and id not in (#{user.has_read_message_ids_arr.join(',')})")
			end
		end
		
	end

	def target= value
		if value != 'all'
			value =  ',' + value.split(',').uniq.delete_if{|x| x.blank?}.join(',') + ','
		end
		write_attribute('target', value)
	end

	def mold
		target == 'all' ? '系统' : '个人'
	end

	# => 判断一个用户的一条信息是不是已读的
	def has_read?(user)
		user.has_read_message_ids_arr.include?(self.id.to_s)
	end

	def belongs_to?(user)
		self.target.split(',').include?(user.id)
	end

end
