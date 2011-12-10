# Methods added to this helper will be available to all templates in the application.
require "form_builder"
require 'open-uri'
require 'iconv'
require 'base64'
module ApplicationHelper
  include ActionView::Helpers::JavaScriptHelper
  extend ActiveSupport::Memoizable

	# => 转换成百分比：50 -> 50%
  def percentize(number)
    number_to_percentage(number, :precision => 0)
  end
  memoize :percentize

	# => 时间本地化处理
	def _l(datetime)
		datetime ||= Time.now
		l datetime, :format => :long
	end

	# => 一个固定的时间戳，用来给外部引用的css\js文件加时间戳
	def timestamp
		'2011-03-15 12:00:00'.to_datetime.to_i
	end

  # => 拖动条Helper方法，init_value设置初始化百分比，动态百分比显示在id为 name + '_message'的区域中。
  def slide_select_for(name, init_value, options = {})
    js = javascript_tag %~
		$(function() {
        //拖延提醒百分比
        $( '##{name}_slider' ).slider({
						value: #{init_value || 0},
						orientation: 'horizontal',
						range: 'min',
						animate: true,
						change: function(event, ui) { $( '##{name}_message' ).html(ui.value + '%'); $( '##{name}' ).val( ui.value ); }
					});
      })~
    js + content_tag(:div, '', options.merge!(:id => "#{name}_slider"))
  end

  # => 判断是不是用户中心页面
  def user_center?
    controller.controller_name == 'users' && controller.action_name == 'show'
  end
  memoize :user_center?

  # => 判断是否显示search表单
  def render_search?
    !%(users site registrations).include?(controller.controller_name)
  end

  # => 返回完整的本站URL,例如 http://www.abc.com:3000
  def full_host
    @full_host ||= request.protocol + request.host_with_port
  end

  def edit_link_to(record)
    %!<a href="/#{record.class.name.tableize}/#{record.id}/edit" class="action_icon"><span class="ui-icon-red ui-icon-pencil icon_span"></span>编辑</a>!
  end

  def delete_link_to(record)
		%~<a href="/#{record.class.name.tableize}/#{record.id}" class="action_icon" data-confirm="你确定要这么做吗?" data-method="delete" rel="nofollow"><span class="ui-icon-red ui-icon-trash icon_span"></span>删除</a>~
  end

	# => 格式化IP，变成可以作为HTML class的样式：115.193.143.36 => 11513021841651931302184165143130218416536
	def format_ip(ip)
		@format_ip = {}
		@format_ip[ip] ||= (
			ip ||= request.remote_ip
			ip.gsub(/\./,Time.now.to_i.to_s)
		)
	end

end
