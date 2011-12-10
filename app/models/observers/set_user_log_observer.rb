class SetUserLogObserver < ActiveRecord::Observer
	# == 用来记录用户日志的公共观察者
	observe :feedback, :style, :website

	# => 保存后记录日志
	def after_create(record)
		record.user.add_log("#{record.class.name}", record.id, %!创建了#{record.class.model_name.human}<a href="/#{record.class.name.tableize}/#{record.id}">#{(record.attributes['title'] || record.attributes['name']).to_s.cut(16)}</a>!, nil)
	end

	# => 更新后记录日志
	def after_update(record)
		record.user.add_log("#{record.class.name}", record.id, %!更新了#{record.class.model_name.human}<a href="/#{record.class.name.tableize}/#{record.id}">#{(record.attributes['title'] || record.attributes['name']).to_s.cut(16)}</a>!, nil)
	end

	# => 删除前记录日志
	def before_destroy(record)
		record.user.add_log("#{record.class.name}", record.id, %!#{record.class.model_name.human}<a href="javascript: alert('已被删除！');">#{(record.attributes['title'] || record.attributes['name']).to_s.cut(16)}</a>被删除!, nil)
	end
	
end
