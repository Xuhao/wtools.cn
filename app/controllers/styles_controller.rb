class StylesController < ApplicationController
	cache_sweeper :style_sweeper, :task_sweeper, :only => [:create, :update, :destroy]

  def index
    @styles = current_user.styles
    @title = '我的样式库'
  end

	def show
		@style = current_user.styles.find(params[:id])
		@title = '样式预览'
		render :edit
	end

  def new
    @style = current_user.styles.new
    @title = '创建新的样式'
  end

  def edit
    @style = current_user.styles.find(params[:id])
    @title = '编辑样式'
  end

  def create
    begin
      if style = current_user.styles.find_by_name(params[:style][:name], :select => 'id,name,user_id')
        style.update_attributes!(params[:style])
        text = "样式『#{style.name}』更新成功！"
      else
        style = current_user.styles.create!(params[:style])
        text = "样式创建成功！"
      end
      if task = Task.find_by_id(params[:task_id]) and task.style_id != style.id
        text = "样式已保存并已关联！整个创建过程已经完成！" if task.update_attribute('style_id', style.id)
      end
    rescue Exception => e
      text = e
    end
    render :text => text
  end

  def update
		begin
			@style = current_user.styles.find_by_name(params[:style][:name]) || current_user.styles.find(params[:id])
			@task = Task.find_by_id(params[:task_id]) if params[:task_id]
			if @style.update_attributes(params[:style])
				@task.update_attribute('style_id', @style.id) if @task and @task.style_id != @style.id
				text = '样式更新成功！'
			else
				text = '样式更新失败！'
			end
		rescue Exception => e
      text = e
    end
    render :text => text
  end

  def destroy
    @style = current_user.styles.find(params[:id])
    @style.destroy
    redirect_to styles_url, :notice => t("flash.success.delete", :model => Style.model_name.human)
  end

  # => 验证样式是否已存在
  def check
    unless params[:name].blank?
      text = current_user.styles.find_by_name(params[:name], :select => 'id') ? 'ok' : 'no'
    end
    render :text => text || 'undefined'
  end

  # => 根据名称查询样式，返回样式的属性
  def get_setting
    unless params[:name].blank?
      style = current_user.styles.find_by_name(params[:name])
    end
    render :json => style.attributes.delete_if { |key, value| %w(id name created_at updated_at).include? key }.to_json
  end

end