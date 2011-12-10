class TaskSweeper < ActionController::Caching::Sweeper
  observe Task, Plan, Job

  def after_create(task)
		expire_cache_for(task)
  end
	
  def after_update(task)
		expire_cache_for(task)
  end

  def after_destroy(task)
		expire_cache_for(task)
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
  end
end