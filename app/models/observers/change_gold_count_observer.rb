# == 专门用来操作金币
class ChangeGoldCountObserver < ActiveRecord::Observer
	observe :Task, :feedback
	
	# => 创建时，增加对应的金币
	def after_create(record)
		gold_count = User::GOLD_ASSIGN[record.class.name]
		record.user.change_gold_count(gold_count) # 操作金币
		reason = %~创建了新的#{record.class.model_name.human}~
		record.user.change_gold_logs(record.id, reason, gold_count) # 记录日志
	end

	# => 删除时，减少对应的金币
	def before_destroy(record)
		gold_count = -User::GOLD_ASSIGN[record.class.name]
		record.user.change_gold_count(gold_count) # 操作金币
		reason = %~删除了一个#{record.class.model_name.human}~
		record.user.change_gold_logs(record.id, reason, gold_count) # 记录日志
	end
	
end