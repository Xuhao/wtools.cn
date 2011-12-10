class FeedbacksController < ApplicationController

  def index
    @title = '反馈中心'
    @feedbacks = params[:user_id].blank? ? Feedback : Feedback.where(:user_id => params[:user_id])
    @feedbacks = @feedbacks.page(params[:page])
  end

  def show
    @title = '查看反馈信息'
    @feedback = Feedback.find(params[:id], :include => :replies)
  end

  def new
    @title = '发表新的反馈'
    @feedback = current_user.feedbacks.new
  end

  def edit
    @title = '编辑反馈信息'
    @feedback = current_user.feedbacks.find(params[:id])
  end

  def create
    @feedback = params[:model_type].blank? ? current_user.feedbacks.new(params[:feedback]) : current_user.__send__(params[:model_type].tableize).new(params[:feedback])
    if @feedback.save
      redirect_to feedback_path(@feedback), :notice => t("flash.success.create", :model => Feedback.model_name.human)
		else
			render :new
		end
	end

	def update
		@feedback = current_user.feedbacks.find(params[:id])
		if @feedback.update_attributes(params[:feedback])
			redirect_to feedback_path(@feedback), :notice => t("flash.success.update", :model => Feedback.model_name.human)
		else
			render :edit
		end
	end

	def destroy
		@feedback = current_user.feedbacks.find(params[:id])
		@feedback.destroy
		redirect_to feedbacks_url, :notice => t("flash.success.delete", :model => Feedback.model_name.human)
	end

	def vote
		if request.post? and !params[:vote_type].blank? and !params[:id].blank?
			Feedback.increment_counter(params[:vote_type], params[:id])
			feedback = Feedback.find_by_id(params[:id], :select => 'id, title')
			vote_type = params[:vote_type] == 'agree_num' ? '赞成' : '反对'
			current_user.add_log("Feedback", feedback.id, %!对反馈<a href="/feedbacks/#{feedback.id}">#{feedback.title.cut(10)}</a>投了#{vote_type}票!, request.query_string)
			status = 200
		else
			status = 500
		end
		render :nothing => true, :status => status
	end
end
