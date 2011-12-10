class StyleSweeper < ActionController::Caching::Sweeper
  observe Style

  def after_create(style)
		style.tasks.each do |task|
			expire_cache_for(task)
		end
  end

  def after_update(style)
		style.tasks.each do |task|
			expire_cache_for(task)
		end
  end

  def after_destroy(record)
		style.tasks.each do |task|
			expire_cache_for(task)
		end
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