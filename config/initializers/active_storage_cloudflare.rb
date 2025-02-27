Rails.application.config.after_initialize do
  if Rails.application.config.active_storage.service == :cloudflare
    # Use Rails storage proxy for secure URL generation
    Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # Configure S3 client options
    service = ActiveStorage::Blob.service
    if service.is_a?(ActiveStorage::Service::S3Service)
      # Access the underlying AWS SDK client
      s3_client = service.client.client

      # Configure the client
      s3_client.config.signature_version = "v4"

      # Set reasonable defaults for CloudFlare R2
      s3_client.config.force_path_style = true
      s3_client.config.retry_limit = 3
    end
  end
end
