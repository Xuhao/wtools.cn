class QuestionsController < ApplicationController
	before_filter :authenticate_admin!, :except => [ :index, :show ]

  def index
    @questions = Question.order('hits desc')
    @title = '帮助中心'
  end

  def show
    Question.increment_counter(:hits, params[:id])
    @question = Question.find(params[:id])
    @title = "#{@question.name} - 帮助中心"
  end

  def new
    @question = Question.new
    @title = '创建新问题'
  end

  def edit
    @title = '编辑问题'
    @question = Question.find(params[:id])
    render :edit
  end

  def create
    @question = params[:model_type].blank? ? Question.new(params[:question]) : params[:model_type].constantize.new(params[:question])
    if @question.save
      redirect_to question_path(@question), :notice => t("flash.success.create", :model => Question.model_name.human)
    else
      render :new
    end
  end

  def update
    @question = Question.find(params[:id])
    if @question.update_attributes(params[:question])
      redirect_to question_path(@question), :notice => t("flash.success.update", :model => Question.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    redirect_to questions_url, :notice => t("flash.success.delete", :model => Question.model_name.human)
  end
end
