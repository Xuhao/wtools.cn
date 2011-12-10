class UserMailer < ActionMailer::Base
  default :from => "Wtools <mail.sender@wtools.cn>"


  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.delay_remind.subject
  #

	# => 进度延期邮件提醒
  def delay_remind(task)
		@task = task
		@user = task.user
		@task_type = task.class.model_name.human
		mail(:to => @user.email,
			:subject => "Wtools - #{@task_type}延迟提醒：#{task.name}已经延迟了#{task.delay_percent}!")
  end

	# => 更新邮件通知
	def update_notice(user)
		@user = user
		mail(:to => @user.email,
			:subject => "Wtools - 网站功能更新通知")
	end

	# => 计划邮件提醒
	def plan_daily_notice(plan)
		@user = plan.user
		@plan = plan
		if plan.local_time_type == '天'
			@time_type = "今天"
		else
			@time_type = "这一#{plan.local_time_type}"
		end
		@title = "计划｛#{plan.name}｝ - #{@time_type}你要做的事情："
		mail(:to => @user.email,
			:subject => "计划｛#{plan.name} - #{plan.current_log.local_index}｝执行提醒 - Wtools") do |format|
			format.html { render :layout => 'mail' }
		end
	end
end