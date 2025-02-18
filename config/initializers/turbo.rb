# frozen_string_literal: true

Rails.application.config.turbo.custom_rendering_options = {
  render_with_defaults: true
}

# Configure Turbo to always reload on back/forward navigation
Rails.application.config.turbo.cache_control = {
  no_cache: true,
  no_store: true,
  must_revalidate: true
}

Turbo::Engine.config.respond_to_formats_on_redirect = true
