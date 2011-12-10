class UtilitiesController < ApplicationController
	before_filter :authenticate_user!
  layout nil
	caches_page :task_chart
	cache_sweeper :style_sweeper, :task_sweeper, :task_log_sweeper, :only => :batch_delete

	# => 获取IP的地理位置信息
	def get_ip_location
		ip = params[:ip].blank_to_nil || request.remote_ip
		render :text => geolocation(ip)
	end

  #	== 搜索公共方法
  def search
		@records = []
    if !params[:klass].blank? and !params[:keyword].blank?
      klass = params[:klass].classify.constantize
      search_fields = model_field_dict[params[:klass].classify]
      find_method = :"#{search_fields.join('_or_')}_contains"

      if klass.column_names.include?('user_id') # 如果是属于当前用户，只搜索属于当前用户的数据
        @records = search_fields ? current_user.__send__(params[:klass].tableize).search(find_method => params[:keyword]).all : []
      else
        @records = search_fields ? klass.search(find_method => params[:keyword]).all : []
      end
    end
  end

  # => 批量删除
  def batch_delete
    begin
      if request.post? and !params[:klass].blank? and !params[:ids].blank?
        unless (ids = params[:ids].split(',')).empty?
          (klass = params[:klass].classify.constantize).transaction do
            klass.find(ids).to_a.each do |x|
              x.destroy
            end
          end
        end
        text = 'OK'
      else
        text = '删除失败！信息：参数错误！'
      end
    rescue Exception => e
      text = '删除失败！'
      text << "<br /><br /><b>错误信息:</b> #{e}" if Rails.env == 'development'
    end
    render :text => text
  end

  # = 应用安装
  def app_install
    if request.post? and !params[:code].blank?
      app_codes = current_user.app_codes.split(',')
      current_user.update_attribute('app_codes', app_codes.unshift(params[:code]).join(',')) unless app_codes.include?(params[:code])
    end
  end

  # = 应用卸载
  def app_uninstall
    if request.post? and !params[:code].blank?
      app_codes = current_user.app_codes.split(',')
      if app_codes.include?(params[:code])
        app_codes.delete(params[:code])
        current_user.update_attribute('app_codes', app_codes.join(','))
      end
    end
  end

	  def images
	    @images = []
	    f = File.open("F:/usefull.txt")
	    f.each { |line| @images << line }
	  end
	#
	  def img
	   @images = []
	    f = File.open("F:/image_path.txt")
	    f.each { |line| @images << line }
	  end
	#
	  def show
	
	  end
	#
	#  def add_img
	#    begin
	#      if params[:name]
	#        f = File.open("F:/usefull.txt", 'a')
	#        f.puts params[:name]
	#        f.close
	#      end
	#      text = '添加成功！'
	#    rescue Exception => e
	#      text = "添加失败！#{e}"
	#    end
	#    render :text => text
	#  end

  # render a picture
  #
  # ":id/:type.png"
  def task_chart 
    task = Task.find(params[:id])
		chart = nil
		if task.ratio.to_i > 0
			chart = send("get_#{params[:type]}chart", task)
		else # 如果一个任务刚刚开始或者用户未设置任何日志的完成百分比时，就不显示效率分析图
			default_img = error_img
		end
		
		respond_to do |format|
			format.png { render :text => chart.try(:fetch) || default_img }
		end

  end

  private
	
  # == 公共搜索，模型-字段对照表，key为模型，value为要检索的字段
  def model_field_dict
    {
			'User' => %w(username),
			'Task' => %w(name description),
			'Plan' => %w(name description),
			'Job' => %w(name description),
			'Style' => %w(name),
			'Website' => %w(name url description),
			'Question' => %w(name answer),
			'Feedback' => %w(title content),
			'UserLog' => %w(content),
			'Message' => %w(title content)
    }
  end

  #
  # must task_log.ratio > 0
  #
  def get_linechart task
    style = task._style
    logs = task.task_logs.take_while{|v| v.done_at < (Date.today + 1.send(task.time_type) + 1)}
		log_size = 0
		once_ratio = 0
		
		if task.log_able
			log_size = logs.length
			max = logs.map{|v| v.ratio}.max
		else
			log_size = task.time_num
			once_ratio = (100 / task.time_num).round(2)
			max = once_ratio
		end

		range = (1..10).map{|i|(max/10.0*i).round(0).to_i}

    chart = GChart.line do |c|
      c.width = log_size * 50
      c.height = 300 + 15 # 15(powered_by)
			c.entire_background = '67676700' # => 图片背景色透明

			if task.log_able
				c.data = [logs.map{|v| v.ratio}]
			else
				c.data = [[once_ratio] * task.time_num ]
			end


      c.axis(:left) { |a|
        a.range = range
        a.labels = range.map{|v| "#{v}%"}
      }

      c.axis(:bottom) { |a|

        a.range = (0..log_size)
        a.labels = (1..log_size).map{|v| %~#{t("words.the")}#{v}#{t("words.#{task.time_type}")}~}
        a.font_size = 12
      }

      # powered by
      c.axis (:bottom) { |a|
        a.labels = ['wtools.cn']
        a.axis_or_tick = "_" 
        a.label_positions = [100-10]
      }

    end

    chart
  end

  #
  # must task_log.ratio > 0
  #
  def get_piechart task
    style = task._style
    logs = task.task_logs.take_while{|v| v.done_at < (Date.today + 1.send(task.time_type) + 1)}

		log_size = 0
		once_ratio = 0

		if task.log_able
			log_size = logs.length
			max = logs.map{|v| v.ratio}.max
		else
			log_size = task.time_num
			once_ratio = (100 / task.time_num).round(2)
			max = once_ratio
		end

		range = (1..10).map{|i|(max/10.0*i).round(0).to_i}

    GChart.pie do |c|
      c.width = 600
      c.height = c.width / 2 + 15 # 15(powered_by)
			c.entire_background = '67676700' # => 图片背景色透明

			if task.log_able
				datas = logs.map{|v| v.ratio}
			else
				datas = [once_ratio] * task.time_num
			end

      datas << 100 - datas.inject(&:+)

      c.data = [ datas ]
      i=-1
      c.labels = (1..log_size).map{|v| %~#{t("words.the")}#{v}#{t("words.#{task.time_type}")}: #{datas[i+=1]}%~} + ["未完成:#{datas[-1]}%"]

    end
  end

end
