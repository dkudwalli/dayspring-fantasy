rate_limit_store =
  if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
    ActiveSupport::Cache::MemoryStore.new
  else
    Rails.cache
  end

Rails.application.config.x.auth_rate_limit_store = rate_limit_store
