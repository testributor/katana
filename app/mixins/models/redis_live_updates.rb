module Models::RedisLiveUpdates
  def redis_live_update_resource_key
    "#{self.class.name}##{id}"
  end
end
