class UsersController < ApplicationController

	# => /home 页面
	def show
		@user_logs = current_user.user_logs.limit(6)
    @title = "用户中心"
  end

	# => 设置头像
	def set_avatar
		@user = current_user
		if request.post? and params[:user]
			if @user.update_attributes(params[:user])
				redirect_to(:back, :notice => '头像设置成功！')
			else
				render :set_avatar, :alert => '头像设置失败！'
			end
		end
	end
=begin
  def index
    @users = User.all
  end

  def show
		@user_logs = current_user.user_logs.all(:limit => 6)
    @title = "用户中心"
  end

  def new
    @user = User.new
    @title = "会员注册"
  end

  def edit
    @user = current_user
    if !params[:type].blank?
      @title = case params[:type]
      when 'info'   then '基本信息修改'
      when 'pwd'    then '密码修改'
      when 'locale' then '语言修改'
      end
    else
      @title = '个人信息修改'
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to(account_url, :notice => '注册成功!欢迎你的加入.')
    else
      render :new
    end
  end

  def update
    @user = current_user
    if @user.update_attributes!(params[:user])
      redirect_to(account_url, :notice => '个人信息更新成功!')
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to(users_url) 
  end
=end
end
