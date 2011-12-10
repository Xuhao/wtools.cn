class WebsitesController < ApplicationController
  include ApplicationHelper
  before_filter :find_or_initialize_website

  def index
    @websites = current_user.websites
    @title = '我的站点列表'
  end

  def show
    @title = '站点信息'
  end

  def new
    @title = '创建新站点'
  end

  def edit
    @title = '站点编辑'
  end

  def create
    @website = current_user.websites.new(params[:website])
    if @website.save
      redirect_to websites_path 
    else
      render :action => "new"
    end
  end

  def update
    if @website.update_attributes(params[:website])
      redirect_to websites_url, :notice => t("flash.success.update", :model => Website.model_name.human)
    else
      render :action => "edit"
    end
  end

  def destroy
    @website.destroy
    redirect_to websites_url, :notice => t("flash.success.delete", :model => Website.model_name.human)
  end

  private
  def find_or_initialize_website
    @website = params[:id] ? current_user.websites.find(params[:id]) : current_user.websites.new
  end

end
