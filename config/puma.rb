# Hobby tier has a limit of 20 connections. We have 5 puma threads
# and 2 worker processed so we need 2 * 5 = 10 total connections.
# The pool in database.yml should be 5 since each process has it's own pool.
# (It can be larger that that but we need at least 5).
# This way the connection limit won't be reached and all threads will be able
# to connect.
# https://github.com/mperham/sidekiq/wiki/Advanced-Options#concurrency
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection

  Katana::Application.redis =
    if ENV["REDIS_URL"]
      Redis.new(url: ENV["REDIS_URL"], db: "katana_#{Rails.env}")
    else
      Redis.new(db: "katana_#{Rails.env}")
    end
end
