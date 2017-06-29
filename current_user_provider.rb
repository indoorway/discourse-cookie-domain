class ExCurrentUserProvider < Auth::DefaultCurrentUserProvider
  TOKEN_COOKIE ||= "_t".freeze

  def log_on_user(user, session, cookies)
    super

    cookies.permanent[TOKEN_COOKIE] = { value: @user_token.unhashed_auth_token, httponly: true, domain: '.indoorway.com' }
  end
end
