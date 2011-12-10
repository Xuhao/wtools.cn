class UsernameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << '不能包含“.”和“/”' if value.to_s.include?('.') or value.to_s.include?('/')
  end
end

require 'digest/md5'
class User < ActiveRecord::Base
	include Erubis::XmlHelper
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :phone_num, :locale, :app_codes, :gold_count,
		:avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :default_avatar, :avatar

	has_attached_file :avatar, :styles => { :medium => "64x64>", :thumb => "40x40>" },
		:default_style => :thumb,
		:default_url => "/images/default_avatar.png",
		:url => "/data/:attachment/:id/:style/:filename",
		:path => ":rails_root/public/data/:attachment/:id/:style/:filename"

	validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/png','image/gif'], :message => '图片格式只能是jpg/jpeg/png/gif'
	validates_attachment_size :avatar, :less_than => 1.megabyte, :message => '图片不能大于1M'

	# == 金币分配配置表
	# === 'task' => 5 表示task的相关操作会得到或减少5个金币
	# === 分配规则：
	# ==== 1、会员注册时，初始金币是10
	# ==== 2、会员创建/删除一个task（plan/job），奖励/惩罚5个金币
	# ==== 3、会员将一个日志标志为已做，奖励1个金币
	# ==== 4、会员发表一条有效反馈，奖励2个金币
	GOLD_ASSIGN = {
		'Task' => 5,
		'Job' => 5,
		'Plan' => 5,
		'TaskLog' => 1,
		'Feedback' => 2,
		'JobFeedback' => 2,
		'PlanFeedback' => 2
	}

  has_many :websites, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :plans, :dependent => :destroy
  has_many :jobs, :dependent => :destroy
  has_many :styles, :dependent => :destroy
  has_many :feedbacks, :dependent => :destroy
	has_many :job_feedbacks, :dependent => :destroy
	has_many :plan_feedbacks, :dependent => :destroy
  has_many :replies, :dependent => :destroy
  has_many :user_logs, :dependent => :destroy

  LOGIN_MINIMUM = 3 # 用户名最短长度
  LOGIN_MAXIMUM = 100 # 用户名最长长度
  PASSWORD_MINIMUM = 4 # 密码最短长度

  validates :username, :presence => true, :uniqueness => true, :username => true


	# => 已读信息数组
	def has_read_message_ids_arr
		@has_read_message_ids_arr ||= self.has_read_message_ids.to_s.split(',').uniq.delete_if {|x| x.blank?}
	end

	# => 将email地址转换成MD5码
	def md5_email
		Digest::MD5.hexdigest(email.to_s.strip)
	end
	
	# == 用户gravatar头像
	def gravatar
    "http://www.gravatar.com/avatar/#{md5_email}?s=40&d=mm&d=#{url_encode('http://wtools.cn/images/default_avatar.png')}"
  end

	# => 用户的最终头像，根据default_avatar来确定
	def _avatar
		if default_avatar == 'local'
			avatar.url
		else
			gravatar
		end
	end

  # 中文的界面语言描述
  def __locale
    (locale == 'zh-CN') ? '简体中文' : '英文'
  end

  # == 用户日志公共方法
  # === log_type: 日志类型，一般存放被操作类的名字
  # === relation_id: 存放被操作的实体的ID
  # === content: 日志具体内容
  # === query_string: 被请求的URL参数
  def add_log(log_type, relation_id, content, query_string=nil)
    self.user_logs.create({:log_type => log_type, :relation_id => relation_id, :content => content, :query_string => query_string})
  end

	# == 记录操作用户金币的日志
  # === relation_id: 存放被操作的实体的ID
	# === reason：操作金币的原因说明，具体操作的结果根据gold_count得出（result）。原因和结果组成了content
	# === gold_count: 金币个数
  def change_gold_logs(relation_id, reason, gold_count)
		result = gold_count > 0 ? "获得了#{gold_count}金币奖励" : "失去了#{gold_count.abs}金币"
    self.user_logs.create({:log_type => 'User', :relation_id => relation_id, :content => "#{reason}，#{result}", :gold_count => gold_count})
  end

	# == 改变用户的金币数
	# === change_gold_count(2): 增加2个金币；
	# === change_gold_count(-3): 减少3个金币；
	def change_gold_count(num)
		User.update_counters self.id, :gold_count => num.to_i
	end


end
