require "browser"
require "browser/aliases"

Browser::Base.include(Browser::Aliases)

# Configure browser middleware
Rails.configuration.middleware.use Browser::Middleware do
  # Add any browser-specific redirects or handling here
end
