# Image Handling in BentoBook Server

## Overview
BentoBook Server uses Active Storage with Cloudflare R2 for image storage and processing. Images are processed during upload to create multiple variants for different use cases, optimized for web delivery using libvips.

## Storage Configuration
Images are stored on Cloudflare R2. The configuration is defined in `config/storage.yml`:

```yml
cloudflare:
  service: S3
  endpoint: https://<account_id>.r2.cloudflarestorage.com
  access_key_id: <%= Rails.application.credentials.dig(:cloudflare, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:cloudflare, :secret_access_key) %>
  region: auto
  bucket: <%= Rails.application.credentials.dig(:cloudflare, :bucket_name) %>-<%= Rails.env %>
```

## Image Processing
Images are processed using the `image_processing` gem with the `vips` processor for better performance. Processing happens in two ways:

1. **On Upload (Compression)**: Through `ImageHandlingService` for avatars and profile pictures
2. **On Demand**: Through Active Storage variants for general images

### Image Variants
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

### Upload Compression
For avatar uploads, images are automatically compressed using these settings:
```ruby
resize_to_limit: [1200, 1200]
format: :jpg
saver: { quality: 73, strip: true }
```

## Components
The application includes several components for handling images:

### S3ImageComponent
A ViewComponent that handles rendering images with proper variants:

```ruby
class S3ImageComponent < ViewComponent::Base
  def initialize(image:, size: :medium, html_class: nil, data: {})
    @image = image
    @size = size
    @html_class = html_class
    @data = data
  end
end
```

Usage:
```erb
<%= render(S3ImageComponent.new(image: user.avatar, size: :thumbnail)) %>
```

### GalleryComponent
Handles displaying multiple images in a grid layout with modal view support:

```ruby
class GalleryComponent < ViewComponent::Base
  def initialize(images:, columns: 3)
    @images = images.is_a?(Array) ? images : Array(images)
    @columns = columns
  end
end
```

Usage:
```erb
<%= render(GalleryComponent.new(images: @restaurant.images)) %>
```

### ImageUploadComponent
Handles image upload UI with preview functionality:

```ruby
class ImageUploadComponent < ViewComponent::Base
  def initialize(form, imageable, template = nil)
    @form = form
    @imageable = imageable
    @template = template
  end
end
```

Usage:
```erb
<%= render(ImageUploadComponent.new(form, @restaurant)) %>
```

## Models
Several models use image attachments through Active Storage:

1. **Image** - General purpose images (polymorphic)
   ```ruby
   has_one_attached :file
   belongs_to :imageable, polymorphic: true
   ```

2. **Profile** - User avatars
   ```ruby
   has_one_attached :avatar
   ```

3. **Contact** - Contact avatars
   ```ruby
   has_one_attached :avatar
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