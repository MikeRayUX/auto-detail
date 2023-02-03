# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AutoDetail
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # DISABLES SPROCKETS MIGHT FIX WEBPACKER COMPILING.... HANGING IN DEVELOPMENT 12/2/2020
    config.assets.enabled = false

    config.time_zone = 'America/Los_Angeles'
		config.active_record.default_timezone = :local
		
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.to_prepare do
      # Devise::SessionsController.layout "authentication/sign_up_in_out_layout"
      # Devise::RegistrationsController.layout "authentication/sign_up_in_out_layout"
      # Devise::ConfirmationsController.layout "authentication/sign_up_in_out_layout"
      # Devise::UnlocksController.layout "authentication/sign_up_in_out_layout"
      # Devise::PasswordsController.layout "authentication/sign_up_in_out_layout"
    end
  end
end
