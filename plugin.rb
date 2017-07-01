# name: discourse cookie domain setup
# about: modifications for Citizen forums
# version: 0.1
# authors: ntauthority

load File.expand_path("../current_user_provider.rb", __FILE__)

Discourse.current_user_provider = ExCurrentUserProvider

after_initialize do
  Discourse::Application.config.session_store(
    :discourse_cookie_store,
    key: '_forum_session',
    domain: '.indoorway.com',
    path: (Rails.application.config.relative_url_root.nil?) ? '/' : Rails.application.config.relative_url_root
  )
end
