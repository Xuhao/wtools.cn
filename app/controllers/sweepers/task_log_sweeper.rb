class TaskLogSweeper < ActionController::Caching::Sweeper
  observe TaskLog

  def after_create(task_log)
		expire_cache_for(task_log.task)
  end

  def after_update(task_log)
		expire_cache_for(task_log.task)
  end

  def after_destroy(task_log)
		expire_cache_for(task_log.task)
  end

  private
  def expire_cache_for(task)
		user = task.user
		task_type = task.type.tableize
		expire_action(:controller => 'site', :action => 'task_show', :username => user.username, :type => task_type, :id => task.id, :format => 'png')
		expire_action(:controller => 'site', :action => 'task_show', :username => user.username, :type => task_type, :id => task.id)
		expire_action(:controller => 'site', :action => 'task_show', :username => user.username, :type => task_type, :id => task.user.send(task.type.tableize).all.map(&:id).join(','), :format => 'png')
		expire_action(:controller => 'site', :action => 'task_show', :username => user.username, :type => task_type, :id => task.user.send(task.type.tableize).all.map(&:id).join(','))
		expire_action(:controller => 'site', :action => 'task_show', :username => user.username, :type => task_type, :format => 'png')
		expire_action(:controller => 'site', :action => 'task_show', :username => user.username, :type => task_type)
		%w(line pie).each do |type|
			expire_page("/utilities/task_chart/#{task.id}/#{type}.png")
		end
  end
end