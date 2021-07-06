# frozen_string_literal: true

source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "bootsnap"
gem "composite_primary_keys"
gem "google-cloud-bigquery"
gem "govuk_app_config"
gem "pg"
gem "puma"
gem "rails", "6.0.4"
gem "rest-client"
gem "sidekiq"

group :development, :test do
  gem "byebug"
  gem "climate_control"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "simplecov"
  gem "webmock"
end

group :development do
  gem "awesome_print"
  gem "listen"
  gem "pry-rails"
end
