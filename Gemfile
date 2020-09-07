# frozen_string_literal: true

source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "bootsnap", ">= 1.4.2"
gem "composite_primary_keys", "~> 12.0.0"
gem "pg"
gem "puma", "~> 4.3"
gem "rails", "~> 6.0.3", ">= 6.0.3.1"
gem "rest-client", "~> 2.1.0"
gem "sentry-raven", "~> 3.0"

group :development, :test do
  gem "byebug"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "simplecov"
  gem "webmock"
end

group :development do
  gem "awesome_print"
  gem "listen", "~> 3.2"
  gem "pry-rails"
end
