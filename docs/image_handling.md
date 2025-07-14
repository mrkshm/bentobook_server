# Image Handling in BentoBook Server

## Overview
BentoBook Server uses Active Storage for handling image uploads and storage. The application employs two different strategies for image processing: one for avatars and another for general, polymorphic images.

## Storage Configuration
Images are stored on Amazon S3 in the production environment. The configuration is defined in `config/storage.yml`:

```yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: eu-west-3
  bucket: bentobook-<%= Rails.env %>
```

## Image Processing
Images are processed using the `image_processing` gem with the `vips` processor for better performance. The processing strategy depends on the type of image.

### 1. Avatars (Pre-processed)
Avatars for both `Contacts` and `Organizations` are pre-processed by the `PreprocessAvatarService` *before* being attached to the model. This service:

*   Validates the file size and type.
*   Converts the image to WEBP format.
*   Creates two variants: a 100x100 thumbnail and a 400x400 medium version.

This manual preprocessing ensures that the variants are created before the record is saved, and it makes the application compatible with storage services that don't support on-the-fly variant generation.

### 2. General Images (On-Demand)
For the polymorphic `Image` model, the application uses the standard Active Storage approach of generating variants on-demand. When a variant is requested for the first time, Active Storage processes the original image and caches the result.

The application defines several standard image sizes used throughout the UI:

```ruby
# Thumbnail (Square)
resize_to_fill: [100, 100]
format: :webp
saver: { quality: 80 }

# Small
resize_to_limit: [300, 200]
format: :webp
saver: { quality: 80 }

# Medium
resize_to_limit: [600, 400]
format: :webp
saver: { quality: 80 }

# Large
resize_to_limit: [1200, 800]
format: :webp
saver: { quality: 80 }
```

## Models
Several models use image attachments through Active Storage:

1.  **Image** - General purpose images (polymorphic)
    ```ruby
    has_one_attached :file
    belongs_to :imageable, polymorphic: true
    ```

2.  **Organization** - User avatars
    ```ruby
    has_one_attached :avatar_medium
    has_one_attached :avatar_thumbnail
    ```

3.  **Contact** - Contact avatars
    ```ruby
    has_one_attached :avatar_medium
    has_one_attached :avatar_thumbnail
    ```

## Frontend Features

### Image Preview
The `ImagePreviewController` (Stimulus) provides client-side image preview functionality:
- Shows thumbnails before upload
- Allows removal of selected images
- Validates file types

### Gallery View
The `GalleryController` (Stimulus) provides:
- Modal image viewer
- Navigation between images
- Touch support for swiping
- Loading states
- Error handling

### Image Deletion
The `ImageDeletionController` (Stimulus) handles:
- Image deletion with confirmation
- DOM updates after successful deletion
- Error handling

## Image Metadata and Time
BentoBook extracts and stores relevant metadata from uploaded images:

### EXIF Data Processing
When images are uploaded, the system extracts EXIF data including:
- Date and time the photo was taken
- Camera model
- Location data (if available)

### Time Handling with Visits
When a visit is created with new images:
1. If no time is specified and images have time metadata, the earliest image time is suggested as the default visit time
2. The user can override this suggestion with a manual time entry
3. All times are stored in UTC and displayed in the user's local timezone

### Privacy Considerations
- By default, EXIF data including timestamps is stripped from public-facing image variants
- Original images with metadata are preserved in storage but not publicly exposed
- Users can opt to remove all metadata from their uploaded images via profile settings

## Best Practices
1. Always use the appropriate variant size for the context to optimize bandwidth
2. Use the `lazy` loading attribute for images below the fold
3. Include proper error handling for failed uploads
4. Use WebP format for variants to optimize delivery
5. Consider accessibility by including proper alt text
6. Validate file types and sizes on both client and server side
7. When creating visits with images, use image metadata to suggest visit times but allow user overrides
