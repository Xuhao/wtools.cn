class TaskLogDoneAtValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << I18n.t('activerecord.errors.messages.greater_than_or_equal_to', :count => record.task.begin_at) if value < record.task.begin_at
  end
end

class TaskLogRatioValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
		record.errors.add(attribute, :less_than_or_equal_to, count: record.can_max_ratio+'%') unless value <= record.can_max_ratio
  end
end

class TaskLog < ActiveRecord::Base
  belongs_to :task
  belongs_to :plan,:class_name => "Plan", :foreign_key => "task_id"
  belongs_to :job,:class_name => "Job", :foreign_key => "task_id"
  # => 找到已完成的logs: TaskLog.done_logs(1)将找到task_id为1的已完成的logs
  scope :done_logs,  lambda { |task_id| where(:done => true, :task_id => task_id) }

  validates :task_id, :presence => true
	validates :evaluation, :numericality => true, :allow_nil => true
	validates :ratio, :numericality => true, :inclusion => {in:(0..100)}
  validates :done_at, :task_log_done_at => true
  validates :ratio, :task_log_ratio => true

	before_update :set_done
	after_save :update_task_completed_ratio

	paginates_per 5
	
  class << self
    # => 根据条件找到某个task日志的个数
    def done_size(task, options = {})
      conditions = {:task_id => task.id}
      if options[:done] == true
        conditions.merge!({:done => true})
      elsif options[:done] == false
        conditions.merge!({:done => false})
      end
      TaskLog.count(:conditions => conditions)
    end
  end

  # = 创建或编辑日志时，完成百分比可取最大的值
	# == 一般日志都是在task创建好就自动创建。所以只会在更新的时候去设置每次完成进度。
	# == 这个最大值为了保证，当前日志的百分比小于整个task剩余的百分比。
  def can_max_ratio
    if self.new_record?
      100 - self.task.ratio.to_i
    else
      if self.ratio_changed?
        100 - (self.task.ratio.to_i - self.ratio_was)
      else
        100 - (self.task.ratio.to_i - self.ratio)
      end
    end
  end

	# 判断日志在当天是否可以更改ratio.
	# 符合以下两种情况的task_log可以编辑ratio：
	# 第一种：日志的done_at早于当天，并且ratio为0
	# 第二种：日志的done_at包含当天，不管ratio是不是为0都可以编辑ratio.
	# 关于第二种情况，dont_at包含当天的解释：
	# 1：task的time_type是day,self.done_at == Date.today 算是包含当天
	# 2: task的time_type是week,上次的done_at < Date.today < self.done_at,如果self就是第一个，那么task的begin_at就作为上次的done_at
	# 3: task的time_type是month\quarter\year时，跟week大同小异。
	def ratio_editable?
		if self.done_at.to_date == Date.today # done_at等于当天
			true
		elsif self.done_at.to_date < Date.today and self.ratio.to_i == 0 #done_at早于当天，并且ratio为0
			true
		elsif self.done_at.to_date > Date.today and self.task.time_type != 'Day' # done_at大于当天，并且task的时间类型不是'Day'
			if first_log? # 如果是task的第一个日志，那么当前日志的时间间隔是task的begin_at到日志的done_at
				return true	if self.task.begin_at.to_date <= Date.today
			else # 如果不是task的第一个日志，当前日志时间间隔是上一个日志的done_at到当前日志的done_at
				return true if Date.today > previous_log.done_at.to_date
			end
		end
	end

	def index
		self.task.task_logs.index(self).to_i + 1
	end

	def local_index
		%~#{I18n.t("words.the")}#{index}#{I18n.t("words.#{task.time_type}")}~
	end

	# => 前一个log,如果自己是第一个log，就返回自己。
	def previous_log
		return self if first_log?
		current_index = self.task.task_logs.index(self)
		self.task.task_logs[current_index - 1]
	end

	# => 当前log是不是第一个log
	def first_log?
		self.task.task_logs.first == self
	end


  private

	# => 更新log时，如果百分比不等于0就设置为已完成
  def set_done
		self.done = true unless self.ratio == 0
  end

	# => 当百分比改变时，重新计算task已完成百分比，并更新到数据库。
	def update_task_completed_ratio
		if self.ratio_changed?
			self.task.update_completed_ratio
		end
	end

end
