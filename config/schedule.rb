# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# deploy on server:
# 1. su root
# 2. crontab -r
# 3. cd RAILS_ROOT
# 4. /usr/local/ruby/bin/whenever --update-crontab store

set :output, "/var/www/wtools/log/cron.log"
job_type :rake2, "cd :path && RUBYOPT=-Ku RAILS_ENV=:environment rake :task :output"

# 更新应完成百分比
every 1.day, :at => '4:00 am' do
  rake2 "update_task:cron_day_task"
end

every :monday, :at => '4:00 am' do
  rake2 "update_task:cron_week_task"
end

every 1.month, :at => '4:00 am' do
  rake2 "update_task:cron_month_task"
end

every 3.month, :at => '4:00 am' do
  rake2 "update_task:cron_quarter_task"
end

every 12.month, :at => '4:00 am' do
  rake2 "update_task:cron_year_task"
end

# 发送延期提醒邮件
every 1.day, :at => '4:30 am' do
  rake2 "send_mail:send_delay_email", :output => "/var/www/wtools/log/send_mail.log"
end

# 计划提醒邮件
every 1.day, :at => '6:30 am' do
  rake2 "send_mail:plan_notice", :output => "/var/www/wtools/log/send_mail.log"
end

# 自动清理超过 30 天的日志信息
every 1.day, :at => '3:30 am' do
  rake2 "daily_task:clean_user_log"
end

# 数据库定时备份
every 1.day, :at => '5:00 am' do
  command "/home/system/db_backup.sh", :output => "/var/www/wtools/log/db_backup.log"
end


# Learn more: http://github.com/javan/whenever
