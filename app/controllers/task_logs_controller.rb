class TaskLogsController < ApplicationController
  before_filter :find_task
	cache_sweeper :task_log_sweeper, :task_sweeper, :only => [:create, :update, :destroy, :save_log]

  def new
    @task_log = @task.task_logs.new
    @title = '写新日志'
  end

  def edit
    @task_log = @task.task_logs.find(params[:id])
    @title = '日志编辑'
    if @task_log
      render :edit
    else
      redirect_to task_url(@task)
    end
  end

  def create
    @task_log = @task.task_logs.new(params[:task_log])
    if @task_log.save
      redirect_to task_url(@task), :notice => t("flash.success.create", :model => TaskLog.model_name.human)
    else
      render :new, :notice => 'TaskLog was not successfully created.'
    end
  end

  def update
    @task_log = @task.task_logs.find(params[:id])
    if @task_log.update_attributes(params[:task_log])
      redirect_to task_url(@task), :notice => t("flash.success.update", :model => TaskLog.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @task_log = @task.task_logs.find(params[:id])
    @task_log.destroy
    redirect_to task_url(@task), :notice => t("flash.success.delete", :model => TaskLog.model_name.human)
  end

  def save_log
    if task_log = @task.task_logs.find_by_id(params[:log_id])
			task_log.update_attributes!(:ratio => params[:percent].to_i, :content => params[:content].blank_to_nil || task_log.content, :evaluation => params[:evaluation].to_i.zero_to_nil || task_log.evaluation)
    end
    render :layout => false
  end

  private

  def find_task
    @task_id = params[:task_id]
		@task = current_user.tasks.find(@task_id)
    return(redirect_to(tasks_url)) if !@task_id or !@task
  end

end
