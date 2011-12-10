class ReplyObserver < ActiveRecord::Observer
	# => 保存后记录日志
	def after_create(reply)
		reply.user.add_log("Reply", reply.id, %!对一条反馈发表了评论<a href="/feedbacks/#{reply.feedback_id}##{reply.id}">去看看</a>!, nil)
	end

	# => 更新后记录日志
	def after_update(reply)
		reply.user.add_log("Reply", reply.id, %!更新了一条反馈评论<a href="/feedbacks/#{reply.feedback_id}##{reply.id}">去看看</a>!, nil)
	end

	# => 删除前记录日志
	def before_destroy(reply)
		reply.user.add_log("Reply", reply.id, %!你的一条反馈评论被删除!, nil)
	end
end
