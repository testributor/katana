# Hobby tier has a limit of 20 connections. We have 5 puma threads so we set
# WORDER_THREADS to 15. This way the connection limit won't be reached.
# https://github.com/mperham/sidekiq/wiki/Advanced-Options#concurrency
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: bundle exec sidekiq -c ${WORKER_THREADS:-3} -q mailers -q default -q low
