# name: discourse cookie domain setup
# about: modifications for Citizen forums
# version: 0.1
# authors: ntauthority

CUSTOM_COOKIE_DOMAIN = '.indoorway.com'.freeze

load File.expand_path('../current_user_provider.rb', __FILE__)
load File.expand_path('../custom_domain_cookie.rb', __FILE__)

Discourse.current_user_provider = ExCurrentUserProvider
Discourse::Application.config.middleware.use 'CustomDomainCookie', CUSTOM_COOKIE_DOMAIN
