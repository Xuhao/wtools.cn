module RepliesHelper
	def reply_children_to_arr(the_reply, arr = [])
		if father_reply = the_reply.reply
			arr << father_reply
			reply_children_to_arr(father_reply, arr)
		end
		arr
	end
end
