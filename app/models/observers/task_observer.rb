class TaskObserver < ActiveRecord::Observer

  def after_update(task)
		unless task.should_completed_ratio_changed?
			log_content = %!更新了#{task.type == 'Plan' ? '计划' : '任务'}<a href="/#{task.type.tableize}/#{task.id}">#{task.name}</a>!
			task.user.add_log(task.type, task.id, log_content, nil)
		end
  end

  def after_create(task)
    log_content = %!创建了新的#{task.type == 'Plan' ? '计划' : '任务'}<a href="/#{task.type.tableize}/#{task.id}">#{task.name}</a>!
    task.user.add_log(task.type, task.id, log_content, nil)
  end

  def before_destroy(task)
    log_content = %!删除了#{task.type == 'Plan' ? '计划' : '任务'}#{task.name}!
    task.user.add_log(task.type, task.id, log_content, nil)
  end

end
