module Utils
	class << self
		# => 反色
		def inverse_color(color)
			correct_color = (color_str = color.delete('#')).size == 3 ?  color_str.split(//).map{|x| x * 2}.join.split(//) : color_str.split(//)
			r,g,b = correct_color.in_groups_of(2).map{|x| x.join}
			(r.to_i(16) + g.to_i(16) + b.to_i(16)) > 382 ?  '#000' : '#FFF'
		end
	end
end
