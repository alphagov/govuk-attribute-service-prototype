# frozen_string_literal: true

source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "bootsnap", ">= 1.4.2"
gem "pg"
gem "puma", "~> 4.1"
gem "rails", "~> 6.0.3", ">= 6.0.3.1"

group :development, :test do
  gem "byebug"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "rubocop-govuk"
end

group :development do
  gem "listen", "~> 3.2"
end
