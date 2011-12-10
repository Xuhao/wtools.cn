namespace :send_mail do
	desc "Send remind email"
  task :send_delay_email => :environment do
    Task.where("status = 'delay' AND email_alert != 0").each do |task|
      task.send_delay_email
    end
  end

	desc "发送网站功能更新提醒邮件"
	task :update_notice => :environment do
		User.all.each do |user|
			UserMailer.update_notice(user).deliver
		end
	end

	desc "计划提醒邮件"
	task :plan_notice => :environment do
		Plan.where(:email_notice => true).each do |plan|
			UserMailer.plan_daily_notice(plan).deliver unless (plan.begin_at > Date.today or plan.end_at < Date.today)
		end
	end
end