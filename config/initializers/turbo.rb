Rails.application.config.turbo.custom_rendering_options = {
  native: {
    layout: "application"
  }
}

Turbo::Engine.config.respond_to_formats_on_redirect = true
