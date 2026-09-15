source "https://rubygems.org"
ruby ">= 3.2.0"

gem "rails", "~> 7.1.3"
gem "pg", "~> 1.5"
gem "puma", "~> 6.4"
gem "redis", "~> 5.0"
gem "sidekiq", "~> 7.2"

# Authentication & Security
gem "devise", "~> 4.9"
gem "pundit", "~> 2.3"
gem "jwt", "~> 2.7"
gem "bcrypt", "~> 3.1.7"

# Asset pipeline & Frontend
gem "importmap-rails", "~> 2.0"
gem "tailwindcss-rails", "~> 2.6"

# Pagination & Filtering
gem "pagy", "~> 6.4"

# Image Processing for Active Storage
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  gem "dotenv-rails", "~> 3.1"
end

group :test do
  gem "shoulda-matchers", "~> 6.0"
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver", "~> 4.18"
  gem "database_cleaner-active_record", "~> 2.1"
end