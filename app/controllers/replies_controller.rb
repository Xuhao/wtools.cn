class RepliesController < ApplicationController

	#  def index
	#    @replies = Reply.all
	#  end
	#
	#  def show
	#    @reply = Reply.find(params[:id])
	#  end

	#  def new
	#    @reply = current_user.replies.new
	#  end

  def edit
    @title = '编辑我的回复'
    @reply = current_user.replies.find(params[:id])
  end

  def create
    @reply = current_user.replies.new(params[:reply])
    @reply.content = @reply.content.gsub(/(<p>)?引用.*?的发言：(<\/p>)?/, '')
    if @reply.save
      redirect_to feedback_path(@reply.feedback, :anchor => @reply.id), :notice => t("flash.success.create", :model => Reply.model_name.human)
    else
      render :new
    end
  end

  def update
    @reply = current_user.replies.find(params[:id])
    if @reply.update_attributes(params[:reply])
      redirect_to feedback_url(@reply.feedback, :anchor => @reply.id), :notice => t("flash.success.update", :model => Reply.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @reply = current_user.replies.find(params[:id])
    @reply.destroy
    redirect_to replies_url, :notice => t("flash.success.delete", :model => Reply.model_name.human)
  end
end
