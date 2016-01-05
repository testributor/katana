# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#timeout
# Disable on development (0 means disable)
Rack::Timeout.timeout = Rails.env.development? ? 0 : 20  # seconds
Rack::Timeout::Logger.level  = Logger::ERROR
