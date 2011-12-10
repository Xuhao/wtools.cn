# To change this template, choose Tools | Templates
# and open the template in the editor.

class String
  # == 将空白转换成nil
  def blank_to_nil
    blank? ? nil : self
  end

  # == 清理HTML标签
  def clean_html
    # self.gsub(/<[^img].*?>/, '')
		self.gsub(/<.*?>/, '')
  end

	# == 删除字符串中的链接(包括被链接的字符)
	def clean_link
		self.gsub(/<a.*?\/a>/,'')
	end

	# == 按照指定的长度截断字符串
  def cut(length, *arg)
    c_str = self.dup
    if c_str.length > length
      c_str[0, length] + (arg.empty? ? '...' : arg[0])
    else
      c_str
    end
  end

end