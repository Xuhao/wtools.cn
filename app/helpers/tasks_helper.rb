module TasksHelper
	include SiteHelper
	STATUS_COLOR = {
		'surpassing' => 'very-good',
		'normal' => 'good',
		'delay' => 'ordinary',
		'closed' => 'bad',
		'completed' => 'done'
	}
	# => task创建流程
  def step
    @step ||= (params[:step] || 'one')
  end

	# => task的展示页面路径
  def show_path(task, username = nil)
		username = (username || task.user.username)
    task_show_path(:username => username, :type => task.class.name.tableize, :id => task.id)
  end

	# => 为task的状态添加颜色
	def color_task_status(task)
		return '' unless task
		%~<span class="#{STATUS_COLOR[task.status]}">#{t("tasks.status.#{task.status}")}</span>~
	end
end
