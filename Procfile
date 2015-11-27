web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c ${WORKER_THREADS:-3} -q mailers -q default -q low
