class UserObserver < ActiveRecord::Observer
  # => 记录日志
  def before_update(user)
    if user.email_changed? or user.phone_num_changed? or user.username_changed?
      user.add_log("User", user.id, '更新了基本信息', nil)
    end
    if user.locale_changed?
      user.add_log("User", user.id, %!将界面语言设置成了<a href="/account/edit/locale">#{user.__locale}</a>!, nil)
    end
    if user.encrypted_password_changed?
      user.add_log("User", user.id, '修改了帐号密码', nil)
    end
		if user.default_avatar_changed?
			user.add_log("User", user.id, '更新了用户头像', nil)
		end
  end
end
