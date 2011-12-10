class SiteController < ApplicationController
	before_filter :authenticate_user!, :only => [:gold_center, :app_center]
	caches_action :task_show
	
  def index
    @title = 'Wtools网络工具箱'
		@keywords = '进度管理,计划管理,任务跟踪'
		@description = 'Wtools网络工具箱提供各种简单实用的小工具。'
  end

	def news
		@tasks = Task.where(:open => true).order('created_at DESC').page(params[:page]).per(10)
		@title = '最新开通的应用'
	end

	def new_apps
		@tasks = Task.where(:open => true).order('created_at DESC').limit(20)
		render :layout => false
	end

	# => 推广功能
	def invite
		if !params[:user_id].blank? and user = User.find_by_id(params[:user_id])
			Ip.touch_ip_for_user(request.remote_ip,user ) # => 记录推广金币
		end
		redirect_to root_url
	end

	# => 计划、任务外部引用地址
  def task_show
		error = false
		begin
			if @_current_user = User.find_by_username(params[:username], :select => 'id,username')
				Ip.touch_ip_for_user(request.remote_ip,@_current_user ) # => 记录推广金币
				select_fields = 'id,style_id,name,completed_ratio,should_completed_ratio,time_num,time_type,aspire_word,last_show_at,log_able'
				if !params[:type].blank?
					first_arg = params[:id].blank? ? :all : (params[:id].split(/,|，|-|\*/).map { |x| x.to_i } & @_current_user.__send__("#{params[:type].downcase.singularize}_ids"))
					@tasks = @_current_user.__send__(params[:type].tableize).find(first_arg, :select => select_fields, :include => :task_logs)
				else
					@tasks = @_current_user.tasks.select(select_fields).include(:task_logs)
				end
				# => 更新最后浏览时间
				@tasks.each do |task|
					task.update_last_show_at
				end

				# => 设置title、keywords、description
				task_names = @tasks.map(&:name).join(',')
				if task_names.blank?
					@title = @keywords = @description = "#{@_current_user.username}的计划任务"
				else
					@title = "#{task_names} - #{@_current_user.username}的计划任务"
					@keywords = task_names
					@description = "#{@_current_user.username}的计划任务,当前展示的任务有：#{task_names}"
				end
			end
		rescue Exception => e
      error = true
    end
		
		respond_to do |format|
			format.html do
				if @tasks.to_a.empty? or error
					render :text => %!您调用的地址不正确！请登陆<a href="http://wtools.cn">Wtools</a>重新获取代码！!
				else
					render :layout => nil
				end
			end
			format.png { render :text => (@tasks.to_a.empty? or error) ? error_img : barchart(@tasks) }
		end
	end

	# => 用户积分中心
	def gold_center
		@title = '积分中心'
		@user_logs = current_user.user_logs.where("gold_count IS NOT NULL")
		@user_logs = @user_logs.page(params[:page]).per(10)
		@gold_top_users = User.order('gold_count DESC').limit(20)
		render :layout => 'member'
	end
	
	# => 应用中心
	def app_center
		@title = '应用中心'
		render :layout => 'member'
	end

	private
	def barchart tasks
		style = tasks[0]._style

		bar = GChart.bar do |c|
			c.width =  style.bar_width
			c.height = (style.bar_height+10) * tasks.length + 15 # 10(margin) +40(title) 15(poweredby)
			c.title = "中文" # make unicode support in Text-Marker
			c.font_size = 0
			c.entire_background = '67676700' # => 图片背景色透明

			c.max	    = 100
			c.data    = [
				tasks.map{|v| v.ratio},
				tasks.map{100}
			]

			c.colors  = [
				style.completed_bgcolor[1..-1],
				style.whole_bgcolor[1..-1]
			]

			tasks.each.with_index do |task, i|
				c.marker(:text) { |m|
          marker =  case style.completed_word_type
					when "ratio"
						"#{task.ratio}%"
					when "time_stamp"
						"#{(task.ratio/100.0*task.time_num).to_i}#{t("words.#{task.time_type}")}"
					when "none"
						""
					end
					m.marker_type = "t#{marker}"
					m.color = Utils.inverse_color(style.whole_bgcolor)
					m.series_index = 0
					m.which_points = i
					m.size = 12
					m.placement = "r"
				}

				c.marker(:text) { |m|
          marker =  case style.whole_word_type
					when "ratio"
						"100%"
					when "time_stamp"
						"#{task.time_num}#{t("words.#{task.time_type}")}"
					when "none"
						""
					end
					m.marker_type = "t#{marker}"
					m.color = Utils.inverse_color(style.whole_bgcolor)
					m.series_index = 1
					m.which_points = i
					m.size = 12
					m.placement = "r"
				}

			end

			c.axis(:left) { |a|
				a.labels = tasks.map(&:name).reverse
				a.axis_or_tick = "_" # hide axis and trick
			}

=begin
      c.axis(:bottom) { |a|
        a.font_size = 0   # hide text
        a.axis_or_tick = "_" 
      }
=end

			# powered by
			c.axis (:bottom) { |a|
				a.labels = [DOMAIN]
				a.axis_or_tick = "_"
				a.label_positions = [c.max-15]
			}

			c.extras = { }
		end
		#p bar.to_url

		bar.fetch
	end
end
