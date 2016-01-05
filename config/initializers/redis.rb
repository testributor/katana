# TODO: Consider using the "with" method if it becomes a problem:
# https://github.com/mperham/connection_pool#migrating-to-a-connection-pool
redis_pool_size = ENV["REDIS_POOL_SIZE_PER_PROCESS"] || 5
Katana::Application.redis =
  if ENV["REDIS_URL"]
    ConnectionPool::Wrapper.new(size: redis_pool_size, timeout: 5) do
      Redis.new(url: ENV["REDIS_URL"], db: "katana_#{Rails.env}")
    end
  else
    ConnectionPool::Wrapper.new(size: redis_pool_size, timeout: 5) do
      Redis.new(db: "katana_#{Rails.env}")
    end
  end
