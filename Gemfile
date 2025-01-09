# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.4.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use PostgreSQL as the database for Active Record
gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "dsfr-view-components"

# Mon Devis Sans Oublis custom gems
gem "active_storage-postgresql" # Store file in database
gem "active_storage_validations" # Validate ActiveStorage attachments
gem "good_job" # Postgres-backed job queue
gem "mime-types"
gem "pdf-reader"
gem "rswag-api" # Serves the generated Swagger documentation
gem "rswag-ui" # Provides the Swagger UI interface
gem "sib-api-v3-sdk", require: false # Brevo (ex Sendinblue) API

# Required for langchainrb
gem "csv" # Since Ruby > 3.4.0
gem "faraday"
gem "langchainrb", ">= 0.19" # Framework around LLMs

gem "ostruct" # Since Ruby > 3.4.0

group :development, :test do
  gem "brakeman"
  gem "bundler-audit"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "pry-rails"
  gem "rspec-rails"
  gem "rswag-specs" # Allows API documentation via specs
end

group :test do
  gem "capybara"
  gem "cucumber-rails", require: false
  gem "faker", require: false
  gem "guard"
  gem "guard-cucumber"
  # Ruby 3.4+ compatibility
  # TODO: Use new > 9.0.0 version when available
  # See https://github.com/cucumber/cucumber-ruby/commit/a468bc682eec68ef5b5660a17c4c0e7e52cfc67b
  # And also https://github.com/cucumber/cucumber-ruby/pull/1771
  gem "cucumber", require: false, github: "cucumber/cucumber-ruby", ref: "a468bc6"
  gem "guard-rspec"
  gem "rspec"
  gem "rubocop"
  gem "rubocop-capybara"
  gem "rubocop-factory_bot"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "rubocop-rspec_rails"
  gem "vcr"
  gem "webmock" # Required to intercept HTTP requests
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :production do
  # Monitoring and error reporting
  gem "sentry-rails"
  gem "sentry-ruby"
end
