Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.active_storage.service = :test
  config.action_mailer.delivery_method = :test
end
