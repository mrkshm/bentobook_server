require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bentobook
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    config.active_record.schema_format = :sql

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.middleware.use Rack::Attack

    # Skip Warden JWT Auth middleware since we're using our own implementation
    config.middleware.delete Warden::JWTAuth::Middleware

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    # Permitted locales available for the application
    config.i18n.available_locales = [ :en, :fr ]

    # Set default locale to something other than :en
    config.i18n.default_locale = :en

    # Add lib to autoload paths
    config.autoload_paths += %W[#{config.root}/lib]
  end
end
