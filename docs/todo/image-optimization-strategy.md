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

### 1. Caching via Rails routes (recommended)
Serve images through Rails Active Storage routes and put Cloudflare in front of the app. Cache `/rails/active_storage/*` aggressively.

- In `config/initializers/active_storage.rb` (already configured):
  ```ruby
  # Use proxy so Rails serves bytes that Cloudflare can cache
  config.active_storage.resolve_model_to_route = :rails_storage_proxy
  # Long-lived URL expiries (mostly relevant for direct service URLs)
  config.active_storage.service_urls_expire_in = 1.year
  config.active_storage.urls_expire_in = 1.year
  ```
- Cache headers for Active Storage responses (already added):
  ```ruby
  # config/initializers/active_storage_cache_headers.rb
  headers["Cache-Control"] = "public, max-age=31536000, immutable"
  ```
- In Cloudflare, add a Cache Rule for your app host paths matching `/rails/active_storage/*`:
  - Cache level: Cache everything
  - Edge TTL: 1 year (or Respect origin)
  - Origin cache control: On
  - Cache key: include query string
  - Optional: Bypass cache on cookies = Off (unless your app sets auth cookies on these URLs)

### 2. CDN Integration (Cloudflare in front of Rails)
Put Cloudflare in front of your Rails app (orange-cloud proxy). Keep S3 private; Rails reads from S3, serves the bytes, and Cloudflare caches the route responses on first hit.

- Benefits: simplest path; no S3 origin host header tricks; no public bucket reads; great cache-hit after warmup.
- See [CDN Setup for Image Optimization](./cdn-for-images.md) for Cloudflare Cache Rules and an alternative S3-origin setup.

*Note on R2 vs. S3:* While Cloudflare R2 offers zero egress fees, sticking with the battle-tested S3 for direct uploads is the prudent choice for now to ensure stability. R2 can be considered a future migration path.

### 3. Optional (later): "Display + Original" hybrid
Keep this as a future enhancement for fidelity/monetization. For now, continue with a single attachment per image.

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
If/when adopted, this requires two attachments on the `Image` model:

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

### Phase 1: Foundational Wins (1–2 days)
*Goal: Ship the CDN with minimal changes.*
1.  **Put your app behind Cloudflare** (orange-cloud the apex/host).
2.  **Add Cloudflare Cache Rule**: cache `/rails/active_storage/*` as above.
3.  **Ensure route URLs**: helpers/components use `url_for`/`rails_blob_url` for variants (done in `ImageHelper`).
4.  **Prewarm common variants**: `RAILS_ENV=production bin/rails images:generate_variants`.
5.  **Validate caching**: check Cloudflare cache hit ratio and AWS egress; tune TTLs if needed.

### Phase 2: Performance & UX (3-5 days)
*Goal: Optimize the front-end experience.*
1.  **Implement Lazy Loading & `srcset`:** Update all relevant views to use these attributes on the `display_file` variants.
2.  **WebP Variants:** Ensure all variants are generated in the WebP format.
3.  **Turbo Frame Persistence:** Apply `data-turbo-permanent` to UI elements like avatars.

### Phase 3: Premium Features (2-3 days)
*Goal: Build out the monetization hooks.*
1.  Implement user subscriptions/permissions.
2.  Introduce optional "Display + Original" dual attachments with a background job (if/when needed).
3.  Add the "Download Original" feature for premium users.
4.  Build the bulk export functionality.
