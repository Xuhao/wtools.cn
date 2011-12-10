class Task < ActiveRecord::Base
  #status: normal(正常),delay(延期),surpassing(超前),completed(完成)，closed(关闭)
  belongs_to :user
  belongs_to :style
  has_many :task_logs, :dependent => :destroy
  has_many :done_task_logs, :class_name => "TaskLog", :conditions => "done = #{true}"
  scope :cron_tasks, lambda { |time_type| where(["(status != 'closed' AND status != 'completed') AND time_type = '#{time_type}'"]) }
	scope :recent_tasks, lambda { |size| select('id,name,type,log_able,completed_ratio,should_completed_ratio,created_at').order('created_at DESC').limit(size) }

	delegate :name, :to => :style, :prefix => true, :allow_nil => true

  validates :name, :presence => true, :uniqueness => { :scope => [:user_id, :type] }
  validates :time_type, :begin_at, :presence => true
  validates :time_num, :presence => true, :numericality => true, :inclusion => { :in => (1..100) }
  validates :delay_for_alert, :numericality => { :only_integer => true, :greater_than => 0 }, :if => proc { |task| task.email_alert || task.sms_alert }
  validates :show_site, :presence => true, :if => proc { |task| task.show_control == 1 }

  before_validation :update_delay_for_alert
  before_save :update_end_at, :update_status

  # => 当task没有对于的style时，为了方便，将绑定一个虚拟的style
  def virtual_style
    @virtual_style ||= Style.virtual_style
  end

  # => 始终返回一个style,如果有就返回，如果没有就返回虚拟的style
  def _style
    @_style ||= (style || virtual_style)
  end

	# => 如果不记录日志，应完成和已完成应该相等
	def ratio
		true_ratio = log_able ? completed_ratio : should_completed_ratio
		if true_ratio.to_i < 0 
			0
		elsif true_ratio.to_i > 100
			100
		else
			true_ratio.to_i
		end

	end

  # => 任务的时间周期
  def duration
    @duration ||= %!#{time_num}#{local_time_type}!
  end

	def local_time_type
		@local_time_type ||= I18n.t(".words.#{time_type}")
	end

  # => 在浏览时更新最后展示时间
  def update_last_show_at
    if self.last_show_at.to_s.to_date != Date.today
      self.touch(:last_show_at)
    end
  end

  # => 状态为已完成的日志的个数
  def done_size
    self.task_logs.count(:conditions => {:done => true})
  end

	# => 查询所以已完成的日志
	def done_logs
		TaskLog.done_logs(self.id)
	end

	# => 重新计算已完成百分比，并更新到数据库
	def update_completed_ratio
		completed_ratio = self.task_logs.all.sum(&:ratio)
		self.update_attributes!(:completed_ratio => completed_ratio)
	end

  # 定时任务时判断passed一定时间单位后，是否需要更新数据库,用来定时更新应完成比例
  # 定时任务(天，周，季度，月，年）
  # 1，每天执行时间类型是'天'的task，并且查找结束时间刚好是当天的task
  # 2，周，月，季度，年（每周，每月，每季度，每年）
  def update_should_completed_ratio
    passed_percent =(((Date.today - self.begin_at).days / self.time_num.__send__(self.time_type)) * 100).to_i
		passed_percent = 100 if passed_percent > 100
    unless passed_percent == self.should_completed_ratio
      self.should_completed_ratio = passed_percent
      self.save!
			# => 删除对应的缓存
			Rails.cache.delete("views/wtools.cn/show/#{self.user.username}/#{self.type.tableize}/#{self.id}.png")
			Rails.cache.delete("views/wtools.cn/show/#{self.user.username}/#{self.type.tableize}/#{self.id}")
			Rails.cache.delete("views/wtools.cn/show/#{self.user.username}/#{self.type.tableize}/#{self.user.send(self.type.tableize).map(&:id).join(',')}")
			Rails.cache.delete("views/wtools.cn/show/#{self.user.username}/#{self.type.tableize}/#{self.user.send(self.type.tableize).map(&:id).join(',')}.png")
			Rails.cache.delete("views/wtools.cn/show/#{self.user.username}/#{self.type.tableize}")
			Rails.cache.delete("views/wtools.cn/show/#{self.user.username}/#{self.type.tableize}.png")
    end
  end

	# => 第一个日志
	def first_log
		return nil unless self.log_able
		@first_log ||= self.task_logs.first
	end

	# => 最后一个日志
	def last_log
		return nil unless self.log_able
		@last_log ||= self.task_logs.last
	end

	# = 当前时间对应的日志
	# == 如果task已经结束，当前时间对应最后一个log
	# == 如果task还没开始，当前时间对应第一个log
	def current_log
		@current_log ||= (
			if self.begin_at >= Date.today
				first_log
			elsif self.end_at <= Date.today
				last_log
			else
				self.task_logs.where("done_at >= '#{Date.today}'").first
			end
		)
	end

	# => 延迟的百分比
	def delay_percent
		real_percent = self.should_completed_ratio.to_i - self.completed_ratio.to_i
		real_percent > 0 ? real_percent : 0
	end

	# 邮件提醒，当task延期，并且刚好是延期的第一个时间单位时，发送邮件
	def send_delay_email
		if self.status == 'delay' and self.delay_for_alert > 0 and self.email_alert and
				(self.should_completed_ratio - self.completed_ratio) > self.delay_for_alert and
				(self.should_completed_ratio - self.completed_ratio - (100/self.time_num).to_i) < self.delay_for_alert

			UserMailer.delay_remind(self).deliver

		end
	end


  protected

  # => 当时间类型和时间量改变时，重新生成日志。
	# == 分三种情况：
	# === 只改变时间类型：只改变所有日志的done_at
	# === 只改变时间量：添加或删除缺少或多余的日志
	# === 时间类型和时间量都改变了： 删除所有日志，重新创建
	# == 三种情况都要重新计算应完成百分比
  def rebuild_logs
		if self.time_type_changed? || self.time_num_changed? || self.begin_at_changed?
			chang_num = self.time_num - self.time_num_was # => 计算改变的个数
			if chang_num > 0 # 如果时间量增加了。就为增加的创建日志，并以没改变前的end_at作为begin_at
				(1..chang_num).each do |i|
					self.task_logs.create!( :done_at => self.begin_at )
				end
			else # 如果时间量减少了,就删除多余的日志
				self.task_logs.all[chang_num,chang_num.abs].to_a.each do |log|
					log.destroy
				end
				self.completed_ratio = self.task_logs.all.sum(&:ratio) # 删除多余的日志后，再计算百分比
			end
			task_logs = self.task_logs.all # 由于上面修改了task_logs的个数，所以要重新查询
			# => 上面将task_logs个数校正之后，下面再将done_at校正
			(1..(self.time_num)).each_with_index do |times, index|
				the_done_at = self.begin_at + times.__send__(self.time_type)
				the_done_at -= 1.day if self.time_type == 'day'
				task_logs[index].update_attribute('done_at', the_done_at)
			end
			# 更新应完成百分比
			self.should_completed_ratio = (((Date.today - self.begin_at).days / self.time_num.__send__(self.time_type)) * 100).to_i
			self.should_completed_ratio = 100 if self.should_completed_ratio > 100

		end
	end

	# => 初始创建时，自动生成日志
	def create_task_logs
		(1..(self.time_num)).each do |i|
			the_done_at = self.begin_at + i.__send__(self.time_type)
			the_done_at -= 1 if self.time_type == 'day'
			self.task_logs.create!(
				:done_at => the_done_at
			)
		end
	end

	# => 根据已完成和未完成的大小比较，来设置状态
	def update_status
		if self.log_able && self.should_completed_ratio_changed? || self.completed_ratio_changed?
			self.status = if self.completed_ratio == 100
				'completed'
			elsif self.completed_ratio < self.should_completed_ratio
				'delay'
			elsif self.completed_ratio == self.should_completed_ratio
				'normal'
			elsif self.completed_ratio > self.should_completed_ratio
				'surpassing'
			end
		end
	end

	# => 如果编辑时将短信与邮件提醒改变了，要修正提醒警戒线
	def update_delay_for_alert
		self.delay_for_alert = 0 if !self.sms_alert && !self.email_alert
	end

	# => 当"开始于"或"时间量"发生变化时，更新"结束于"
	def update_end_at
		if self.begin_at_changed? || self.time_num_changed? || self.time_type_changed?
			certain_time_num = self.time_num.__send__(self.time_type)
			certain_time_num -= 1.day if self.time_type == 'day'
			self.end_at = self.begin_at + certain_time_num
		end
	end

	# => 计算实际时间段，返回可与Dates实例直接计算的Integer实例
	def certain_time_num
		self.time_num.__send__(self.time_type)
	end

end
