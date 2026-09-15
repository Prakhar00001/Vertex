Sidekiq.configure_server { |c| c.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") } }
Sidekiq.configure_client { |c| c.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") } }
