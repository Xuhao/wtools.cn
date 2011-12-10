class Ip < ActiveRecord::Base

	# => 判断一个IP是不是24小时内访问过
	def self.in_24h?(ip)
		search(:created_at_greater_than  => Time.now - 1.day, :ip_eq => ip).last
	end

	# => 如果IP不是24小时内访问过，创建或更新IP的created_at，并增加金币，记录日志
	def self.touch_ip_for_user(ip,user)
		unless in_24h?(ip)
			if the_ip = where(:ip => ip).first # 如果数据库里有IP，就更新他的created_at
				the_ip.touch(:created_at)
			else # 没有就创建
				the_ip = create(:ip => ip)
			end
			user.change_gold_count(1) # 增加金币
			#user.change_gold_logs(the_ip.id, '为推广作出了贡献', 1) # 记录日志
		end
	end
	
end
