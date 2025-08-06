# Image Optimization Strategy for BentoBook

## Current Implementation
- Using Active Storage with S3 for image storage.
- Direct uploads from client to S3 with progress tracking.
- Basic variant generation for different display sizes.

## Identified Issues
1.  Images are re-downloaded on every page load due to a lack of caching.
2.  No CDN integration for faster global delivery and reduced S3 costs.
3.  No separation between images for fast display and archival-quality originals.

## Optimization Strategies

### 1. Caching Headers (Server-Side)
The foundation of any caching strategy is telling the browser it's safe to store a local copy. We will configure Rails to send aggressive caching headers for all Active Storage assets.

```ruby
# config/initializers/active_storage.rb or in a relevant controller
# This tells browsers that the content at this URL will never change.
# It's the most effective caching directive for fingerprinted/immutable assets.
Rails.application.config.active_storage.service_urls_expire_in = 1.year
Rails.application.config.action_dispatch.default_headers.merge!(
  'Cache-Control' => 'public, max-age=31536000, immutable'
)
```

### 2. CDN Integration (Cloudflare + Private S3)
A CDN is the single most impactful change for performance and cost savings. We will use Cloudflare to cache our images at the edge, closer to users.

**Strategy: Private S3 Bucket**
To enhance security and control costs, the S3 bucket will be kept **private**. This prevents any direct access and ensures all traffic is served through the CDN.

```yaml
# config/storage.yml
amazon:
  service: S3
  # ... credentials ...
  bucket: your-private-bucket-name
  public: false # Bucket is private
  asset_host: https://cdn.your-domain.com # Public CDN URL
```

**Implementation Note:** See the detailed [CDN Setup Guide](./cdn-for-images.md) for step-by-step instructions on configuring Cloudflare with a private S3 bucket.

*Note on R2 vs. S3:* While Cloudflare R2 offers zero egress fees, sticking with the battle-tested S3 for direct uploads is the prudent choice for now to ensure stability. R2 can be considered a future migration path.

### 3. Hybrid Image Strategy: "Compress-and-Keep"
To provide both a fast, efficient app and a true, archival-quality diary, we will adopt a two-file strategy for every photo.

#### 3.1. The "Display Version"
This is an optimized image used for all in-app rendering. It ensures the app is fast and bandwidth costs are low.

-   **Creation:** When a user uploads a photo, a background job will immediately create this version. It can also be done client-side before upload using a library like `browser-image-compression` to save upload bandwidth.
-   **Specifications:** It should be compressed and resized to a generous but sensible maximum (e.g., 2560px wide, 85% quality, converted to WebP).
-   **Usage:** **The entire application will ONLY use this Display Version.** Every `image_tag`, every variant (`thumb`, `medium`, `large`), will be generated from this file.

#### 3.2. The "Archival Original"
This is the user's original, untouched file, preserved for fidelity and future use.

-   **Storage:** The original file is saved directly to S3 and attached to the record but is **never** loaded by the application for display.
-   **Cost Management:** To manage costs, these original files can be automatically transitioned to a cheaper storage class (e.g., S3 Infrequent Access) after 30-60 days.

#### 3.3. Monetization & User Features
This two-file system creates a clear and valuable premium feature set.

-   **Free Tier:** All users see the fast, high-quality Display Versions.
-   **Premium Tier:** Subscribers gain access to the Archival Originals, with features like:
    -   A "Download Original" button on each image.
    -   A bulk export tool to download all original photos from a visit or date range.

#### 3.4. Model Implementation
This requires two attachments on the `Image` model:

```ruby
class Image < ApplicationRecord
  # For all in-app display and variants
  has_one_attached :display_file

  # The original, for archival purposes (premium feature)
  has_one_attached :original_file
end
```

### 4. Optimized Variants & Formats
All variants will be generated from the `display_file` to ensure they are fast and efficient.

```ruby
# In your Image model
# Variants are defined on the display_file attachment

# image.display_file.variant(:medium)
```

### 5. Client-Side Rendering Optimizations
-   **Lazy Loading:** Add `loading: "lazy"` to all images that are likely to be off-screen.
-   **Responsive Images (`srcset`):** Use `srcset` to allow the browser to download the most appropriately sized variant of the `display_file`.
-   **Turbo Frame Persistence:** For images inside Turbo Frames that should not reload on navigation (e.g., a user avatar), mark the frame as permanent.

## Implementation Plan

### Phase 1: Foundational Wins (3-5 days)
*Goal: Implement the core infrastructure for the hybrid strategy.*
1.  **Set up Cloudflare CDN** with a private S3 bucket.
2.  **Add Caching Headers** via a Rails initializer.
3.  **Update `Image` Model:** Add the `display_file` and `original_file` attachments.
4.  **Implement Background Job:** Create a job that takes an `original_file`, generates the `display_file`, and attaches both.
5.  **Update Upload Logic:** The `image-upload` controller will now trigger this new background job.

### Phase 2: Performance & UX (3-5 days)
*Goal: Optimize the front-end experience.*
1.  **Implement Lazy Loading & `srcset`:** Update all relevant views to use these attributes on the `display_file` variants.
2.  **WebP Variants:** Ensure all variants are generated in the WebP format.
3.  **Turbo Frame Persistence:** Apply `data-turbo-permanent` to UI elements like avatars.

### Phase 3: Premium Features (2-3 days)
*Goal: Build out the monetization hooks.*
1.  Implement user subscriptions/permissions.
2.  Add the "Download Original" feature for premium users.
3.  Build the bulk export functionality.
