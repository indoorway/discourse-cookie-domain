class ExCurrentUserProvider < Auth::DefaultCurrentUserProvider

  def log_on_user(user, session, cookies)
    super
    cookies.instance_variable_get(:@set_cookies)[TOKEN_COOKIE][:domain] = CUSTOM_COOKIE_DOMAIN
  end

end
