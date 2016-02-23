# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#timeout
# Don't override the timeout unless you know what you are doing.
# Rack::Timeout calculates the timeout value by subsctracting the wait time
# from the default of 15 seconds of service time. When timeout is set it is
# always honoured so setting this here might cause the dyno to continue
# processing the request even after the heroku router has closed the connection.
# https://github.com/heroku/rack-timeout#wait-timeout
#
# Disable on development (0 means disable)
if Rails.env.development?
  Rack::Timeout.timeout = 0 # disable
end
Rack::Timeout::Logger.level  = Logger::ERROR
