class ExCurrentUserProvider < Auth::DefaultCurrentUserProvider

  def log_on_user(user, session, cookies)
    super

    data = { value: @user_token.unhashed_auth_token, httponly: true, domain: '.indoorway.com' }
    cookies.permanent['_t'] = data
    cookies.permanent['_forum_session'] = data
  end
end
