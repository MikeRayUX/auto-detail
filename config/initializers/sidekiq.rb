# DOCKER SPECIFIC INITIALIZER
# NOT TO BE RUN IN PRODUCTION/HEROKU
if !Rails.env.production?
  redis_url = "redis://redis/:6379/0"

  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end
end
