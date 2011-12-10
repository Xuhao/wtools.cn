# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'rexml/document'
class ApplicationController < ActionController::Base
  DOMAIN = "wtools.cn" # 网站地址在图片上水印显示

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :extract_locale_from_accept_language_header, :error_img, :admin?
  before_filter :set_locale
  before_filter :authenticate_user!, :if => :authorization_required?
  layout :set_layout

	# => 为找到对应的记录，就跳转到404页面
  rescue_from ActiveRecord::RecordNotFound, :with => :redirect_to_404

  private

	# == 通过有道接口查询IP所在城市、运营商
  def geolocation(ip)
    @geolocation ||= {}
    @geolocation[ip] ||= (
			return '局域网地址' if ip.blank?
			return '本机' if ip =~ /^192\.168.*|^127\.0.*/
			xml = REXML::Document.new(open("http://www.youdao.com/smartresult-xml/search.s?type=ip&q=#{ip}").read)
			xml.elements['//location'].try(:text) || '地理位置未知'
			#ip_info = Iconv.conv("UTF-8","GBK",open("http://int.dpool.sina.com.cn/iplookup/iplookup.php?ip=#{ip}").read).split('	')
			#ip_info[4..6].join + ' ' + ip_info[7]
    )
  end
	helper_method :geolocation
	
  def redirect_to_404
		unless Rails.env.to_s == 'development'
			redirect_to "/404.html", :status => 404
		end
  end

	# => 检查是否是管理员
	def admin?
		current_user.admin
	end

	# => 管理员权限验证
	def authenticate_admin!
		unless admin?
			redirect_to user_root_path
			flash[:alert] = "您无权进入！"
			return false
		end
	end
	
	# 错误图片
	def error_img
		@error_img ||= image = open("#{Rails.public_path}/images/error_img.png", 'rb') { |io| io.read }
	end

  # => 设置locale
	# 暂时取消从用户信息中确定locale，待多语言完善后再恢复。
  def set_locale
    #I18n.locale = cookies[:locale] || current_user.try(:locale)|| extract_locale_from_accept_language_header
		#I18n.locale = cookies[:locale] || extract_locale_from_accept_language_header
		I18n.locale = "zh-CN"
  end

	# == 通过客户端浏览器获取locale
  def extract_locale_from_accept_language_header
    (language = request.env['HTTP_ACCEPT_LANGUAGE'].split(",").first) == 'zh-cn' ? 'zh-CN' : language
  end

  # => 登录前使用"application"模板，登陆使用"member"模板
  def set_layout
    authorization_required? ? 'member' : 'application'
  end

	# == 判断页面是否需要权限验证
	# TODO 使用更严密的策略改进此方法
  def authorization_required?
    not "#{controller_name}##{action_name}" =~ /^site#.*?$|^sessions#.*?$|^confirmations#.*?$|^passwords#(new|create|edit|update)$|^registrations#(new|create)$/
  end
end
