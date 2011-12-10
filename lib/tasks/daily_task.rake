namespace :daily_task do
	desc "自动清理超过 30 天的日志信息"
	task :clean_user_log => :environment do
		UserLog.delete_old_logs
  end
end