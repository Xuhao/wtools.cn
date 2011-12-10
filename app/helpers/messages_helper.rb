module MessagesHelper

	def status(message)
		message.has_read?(current_user) ? '<span class="good">已读</span>' : '<span class="bad">未读</span>'
	end
end
