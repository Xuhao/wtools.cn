module UsersHelper
  def info_edit?
    params[:type] == 'info'
  end

  def pwd_edit?
    params[:type] == "pwd"
  end

  def locale_edit?
    params[:type] == "locale"
  end
end
