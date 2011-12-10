class TaskLogObserver < ActiveRecord::Observer

	# => 当日志状态变化时，增加/减少对应的金币
	def after_update(task_log)
		if task_log.done_changed?
			if !task_log.done_was and task_log.done # 从未做到已做,增
				gold_count = User::GOLD_ASSIGN[task_log.class.name]
			elsif task_log.done_was and !task_log.done # 从已做到未做,减
				gold_count = -User::GOLD_ASSIGN[task_log.class.name]
			end
			task_log.task.user.change_gold_count(gold_count)  # 操作金币
			reason = '更新了计划任务日志'
			task_log.task.user.change_gold_logs(task_log.id, reason, gold_count) # 记录日志

			# => 记录用户日志
      task_log.task.user.add_log("#{task_log.task.type}", task_log.id, %!为#{task_log.task.class.model_name.human}<a href="/#{task_log.task.type.tableize}/#{task_log.task.id}">#{task_log.task.name}</a>写了新的日志!, nil)
		end
	end

	# => 删除时，减少对应的金币
	def before_destroy(task_log)
		if task_log.done
			gold_count = -User::GOLD_ASSIGN[task_log.class.name]
			task_log.task.user.change_gold_count(gold_count)  # 操作金币
			reason = '删除了一条计划任务日志'
			task_log.task.user.change_gold_logs(task_log.id, reason, gold_count) # 记录日志
		end
	end

end
