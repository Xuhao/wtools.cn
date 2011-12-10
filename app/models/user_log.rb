require 'ostruct'
class UserLog < ActiveRecord::Base
	default_scope order('created_at DESC') # 按时间倒叙排列
	belongs_to :user
	delegate :username, :to => :user
	delegate :_avatar, :to => :user, :prefix => true
  scope :important_logs, where("log_type REGEXP 'Task|Job|Plan|Style|Feedback'")

	# => 清理超过30天的日志
	def self.delete_old_logs
		UserLog.delete_all("created_at < '#{(Time.now - 30.days).to_s(:db)}'")
	end

	# == 当找到的用户日志不足size个时，用虚拟日志填充
	def self.fill(size)
    # logs = important_logs.select('user_id, content, created_at').limit(size).group('user_id').all
    logs = find_by_sql("select user_id, content, created_at from (select user_id, content, created_at from user_logs where(log_type REGEXP 'Task|Job|Plan|Style|Feedback') order by created_at desc) user_logs_temp group by user_id order by created_at desc")
		real_size = logs.size
		v_log = OpenStruct.new({:user__avatar => '/images/default_avatar.png', :username => nil, :clear_content => nil})
		logs.fill(v_log, real_size, size - real_size)
	end

	# == 删除日志里的链接，用于在首页显示
	def clear_content
		self.content.clean_link
	end
	
end
