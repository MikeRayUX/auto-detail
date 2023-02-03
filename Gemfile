# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 2.6.1'
gem 'webpacker', '~> 5.x'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'devise'
gem 'jwt'
gem 'rails', '~> 5.2.3'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# for datepicker
gem 'jquery-rails'
gem 'jquery-ui-rails', '5.0.5'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby
gem 'stripe'
# for qr codes
gem 'rqrcode'
gem "attr_encrypted", "~> 3.1.0"
gem 'kaminari'

# for one time passwords
gem 'rotp'
gem 'active_model_otp'

gem 'sitemap_generator'
# gem 'whenever', require: false

# start sidekiq processes
# redis-server
# mailcatcher
# bundle exec sidekiq

gem 'httparty'
gem 'rubocop', '~> 0.70.0', require: false
gem 'sidekiq'
gem 'sinatra'

gem 'sendgrid-ruby'
gem 'clicksend_client', '>= 1.0.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'geocoder'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'stripe_event'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '4.8.2'
  gem 'guard-rspec'
  gem 'mailcatcher'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
	gem 'parallel_tests'
	# bundle exec rake parallel:setup to reload schema and dbs
  # bundle exec rake parallel:spec FOR RSPEC
	# MAGIC COMMAND THAT MAKES PARALLEL WORK
	# bundle config disable_exec_load true
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'annotate', git: 'https://github.com/ctran/annotate_models.git'
  gem 'bullet'
  gem 'faker'
  # for gaurd livereload start
  # gem 'guard'
  # gem 'guard-livereload', '~> 2.5', require: false
  # gem 'rack-livereload'
  # for gaurd livereload end
  gem 'pry-rails'
  gem 'rb-fsevent', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  # gem 'selenium-webdriver'
  gem 'apparition'
  gem 'capybara-screenshot'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'simplecov', require: false, group: :test
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
