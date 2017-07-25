class ExCurrentUserProvider < Auth::DefaultCurrentUserProvider

  def current_user
    return @env[CURRENT_USER_KEY] if @env.key?(CURRENT_USER_KEY)

    # bypass if we have the shared session header
    if shared_key = @env['HTTP_X_SHARED_SESSION_KEY']
      uid = $redis.get("shared_session_key_#{shared_key}")
      user = nil
      if uid
        user = User.find_by(id: uid.to_i)
      end
      @env[CURRENT_USER_KEY] = user
      return user
    end

    request = @request

    user_api_key = @env[USER_API_KEY]
    api_key = request[API_KEY]

    auth_token = request.cookies[TOKEN_COOKIE] unless user_api_key || api_key

    current_user = nil

    if auth_token && auth_token.length == 32
      @user_token = UserAuthToken.lookup(auth_token,
                                         seen: true,
                                         user_agent: @env['HTTP_USER_AGENT'],
                                         path: @env['REQUEST_PATH'],
                                         client_ip: @request.ip)

      current_user = @user_token.try(:user)
    end

    if current_user && should_update_last_seen?
      u = current_user
      Scheduler::Defer.later "Updating Last Seen" do
        u.update_last_seen!
        u.update_ip_address!(request.ip)
      end
    end

    # possible we have an api call, impersonate
    if api_key
      current_user = lookup_api_user(api_key, request)
      raise Discourse::InvalidAccess unless current_user
      raise Discourse::InvalidAccess if current_user.suspended? || !current_user.active
      @env[API_KEY_ENV] = true
    end

    # user api key handling
    if user_api_key

      limiter_min = RateLimiter.new(nil, "user_api_min_#{user_api_key}", SiteSetting.max_user_api_reqs_per_minute, 60)
      limiter_day = RateLimiter.new(nil, "user_api_day_#{user_api_key}", SiteSetting.max_user_api_reqs_per_day, 86400)

      unless limiter_day.can_perform?
        limiter_day.performed!
      end

      unless  limiter_min.can_perform?
        limiter_min.performed!
      end

      current_user = lookup_user_api_user_and_update_key(user_api_key, @env[USER_API_CLIENT_ID])
      raise Discourse::InvalidAccess unless current_user
      raise Discourse::InvalidAccess if current_user.suspended? || !current_user.active

      limiter_min.performed!
      limiter_day.performed!

      @env[USER_API_KEY_ENV] = true
    end

    # keep this rule here as a safeguard
    # under no conditions to suspended or inactive accounts get current_user
    if current_user && (current_user.suspended? || !current_user.active)
      current_user = nil
    end

    @env[CURRENT_USER_KEY] = current_user
  end

  def log_on_user(user, session, cookies)
    super
    data = { value: @user_token.unhashed_auth_token, httponly: true, domain: '.indoorway.com' }
    cookies.permanent['_t'] = data
  end
end
