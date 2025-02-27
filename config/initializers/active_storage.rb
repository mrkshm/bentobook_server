Rails.application.configure do
  # Use vips as the variant processor
  config.active_storage.variant_processor = :vips

  # Configure caching for all variants
  config.active_storage.service_urls_expire_in = 1.hour
  config.active_storage.urls_expire_in = 1.hour

  # Enable variant tracking
  config.active_storage.track_variants = true

  # Set content types that should be treated as images
  config.active_storage.content_types_to_serve_as_binary = %w[
    image/jpeg
    image/jpg
    image/png
    image/gif
    image/webp
  ]

  # Configure default options for all variants
  config.active_storage.variant_configuration = {
    saver: { quality: 80 },
    format: :webp,
    strip: true
  }

  # Configure default options for variants
  config.active_storage.web_image_content_types = %w[image/jpeg image/jpg image/png image/gif image/webp]

  # Enable debug logging in development
  if Rails.env.development?
    ActiveStorage::LogSubscriber.logger = Rails.logger
    ActiveStorage::LogSubscriber.logger.level = :debug
  end
end
