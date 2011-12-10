class TasksController < ApplicationController
  before_filter :find_or_initialize_task, :except => [:index, :show, :create, :new]
  before_filter :find_task_type, :except => [:show, :destroy]
	cache_sweeper :task_sweeper, :only => [:create, :update, :destroy]

  def index
    @tasks = current_user.__send__(@task_type.tableize).select("id,type,name,time_num,time_type,begin_at,completed_ratio,should_completed_ratio,log_able,status")
    @task_class = @task_type.classify.constantize
    @title = "我的#{@task_class.model_name.human}"
  end

  def show
    @task = current_user.tasks.find(params[:id], :include => :task_logs)
    @task_logs = @task.task_logs
    @title = @task.name
  end

  def new
    @task = ((task_id = (params[:task_id] || session[:current_task_id])) && (params[:step] == 'two')) ? current_user.tasks.find_by_id(task_id) : @task_type.classify.constantize.new
    @title = "创建#{@task_type.classify.constantize.model_name.human}"
  end

  def edit
    @title = "编辑#{@task.class.model_name.human}"
  end

  def create
    # render :text => params.inspect
    @task = if params[:plan]
			current_user.plans.new(params[:plan])
		elsif params[:job]
			current_user.jobs.new(params[:job])
		elsif params[:task]
			current_user.tasks.new(params[:task])
		end
		@task.time_num = params[:task_logs].size if params[:task_logs] and @task.time_num != params[:task_logs].size # 当有日志数组时，验证time_num的个数
    if @task and @task.save
			if params[:task_logs] # 保存日志
				params[:task_logs].each_with_index do |task_log_hash, index|
					i = index + 1
					the_done_at = @task.begin_at + i.__send__(@task.time_type)
					the_done_at -= 1 if @task.time_type == 'day'
					@task.task_logs.create!(task_log_hash.merge!({:done_at => the_done_at}))
				end
			end
			session[:current_task_id] = @task.id
			redirect_to("/#{@task.type.tableize}/new/two", :notice => t("flash.success.update", :model => Task.model_name.human))
		else
			render "new", :locals => {:step => 'one'}
		end
	end

	def update
		if @task.update_attributes(params[:plan] || params[:job] || params[:task])
			if params[:task_logs] # 保存日志
				task_logs = @task.task_logs
				params[:task_logs].each_with_index do |task_log_hash, index|
					task_logs[index].update_attributes(task_log_hash)
				end
			end
			redirect_to @task, :notice => t("flash.success.update", :model => Task.model_name.human)
		else
			render :edit
		end
	end

	def destroy
		@task.destroy
		redirect_to :back, :notice => t("flash.success.update", :model => Task.model_name.human)
	end

	protected
	def task_type
		if @task
			@task.class.name.downcase
		elsif params[:type] =~ /^(plan)s?$|^(job)s?$/i
			params[:type].downcase.singularize
		else
			'task'
		end
	end

	# return @task_type
	def find_task_type
		@task_type ||= task_type
	end

	# return @task
	def find_or_initialize_task
		@task ||= (params[:id] ? current_user.tasks.find(params[:id]) : task_type.classify.constantize.new)
	end

end
