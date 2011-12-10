class MessagesController < ApplicationController
	before_filter :authenticate_admin!, :except => [ :index, :show, :read ]

  def index
    @messages = Message.user_messages(current_user)
		@title = '我的信息'
  end


  def show
    redirect_to messages_url
  end

	def read
		if request.post? and params[:id]
			unless current_user.has_read_message_ids_arr.include? params[:id]
				current_user.has_read_message_ids = ',' + (current_user.has_read_message_ids_arr << params[:id].to_i).join(',') + ','
				current_user.save
			end
		end
		render :text => 'ok'
	end

  def new
    @message = Message.new
		@title = '添加新的信息'
  end

  def edit
    @message = Message.find(params[:id])
		@title = '编辑信息'
  end

  def create
    @message = Message.new(params[:message])

		if @message.save
			redirect_to(messages_url, :notice => 'Message was successfully created.')
		else
			render :new
		end
  end

  def update
    @message = Message.find(params[:id])

		if @message.update_attributes(params[:message])
			redirect_to(@message, :notice => 'Message was successfully updated.')
		else
			render :edit
		end
  end
 
  def destroy
    @message = Message.find(params[:id])
    @message.destroy
		redirect_to(messages_url)
  end
end
