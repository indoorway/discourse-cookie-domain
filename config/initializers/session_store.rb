Discourse::Application.config.session_store(
  :discourse_cookie_store,
  key: '_forum_session',
  domain: '.indoorway.com',
  path: (Rails.application.config.relative_url_root.nil?) ? '/' : Rails.application.config.relative_url_root
)
