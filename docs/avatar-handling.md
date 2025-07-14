# Avatar Handling in BentoBook Server

## Overview
BentoBook Server uses a custom preprocessing service to handle avatar images, which are then stored using Rails Active Storage. This approach provides flexibility in image processing and storage, allowing for compatibility with various storage providers, including those that do not support on-the-fly image transformations.

## Storage Configuration
Avatars, like other file uploads, are managed by Active Storage. The storage service is configured in `config/storage.yml`. For the production environment, the application is configured to use Amazon S3:

```yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: eu-west-3
  bucket: bentobook-<%= Rails.env %>
```

While the configuration for Cloudflare R2 is present, it is currently commented out and not in use.

## Avatar Processing
Avatar processing is handled by the `PreprocessAvatarService` before the files are attached to a model. This service is responsible for validation, resizing, and compression.

### 1. On Upload (Preprocessing)
When an avatar is uploaded, the `PreprocessAvatarService` performs the following actions:

*   **Validation**: Checks the file size (up to 10MB) and content type (`image/jpeg`, `image/png`, `image/gif`, `image/webp`).
*   **Conversion**: Converts the uploaded image to the WEBP format for better performance and smaller file sizes.
*   **Variant Creation**: Creates two distinct versions (variants) of the avatar:
    *   **Thumbnail**: Resized to 100x100 pixels with a quality of 80.
    *   **Medium**: Resized to 400x400 pixels with a quality of 90.

This "manual" preprocessing is defined in the service itself:

```ruby
# app/services/preprocess_avatar_service.rb

class PreprocessAvatarService
  # ...
  VARIANTS = {
    thumbnail: {
      size: [ 100, 100 ],
      quality: 80,
      suffix: :thumb
    }.freeze,
    medium: {
      size: [ 400, 400 ],
      quality: 90,
      suffix: :md
    }.freeze
  }.freeze
  # ...
end
```

### 2. Attachment
After the `PreprocessAvatarService` has created the variants, the resulting files are attached to the `Contact` or `Organization` model using Active Storage's `has_one_attached`:

```ruby
# app/models/organization.rb
class Organization < ApplicationRecord
  # ...
  has_one_attached :avatar_medium
  has_one_attached :avatar_thumbnail
  # ...
end
```

## Implications of Manual Preprocessing
By handling all image processing *before* attaching the files to Active Storage, the application does not rely on Active Storage's built-in variant generation. This has the significant advantage of making the application compatible with any storage provider that can be configured with Active Storage, including those like Cloudflare R2 that do not support automatic image resizing.

This design choice gives the application greater flexibility and control over how images are handled, ensuring consistent results regardless of the underlying storage service.
