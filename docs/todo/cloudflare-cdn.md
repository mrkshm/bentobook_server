# Cloudflare CDN Setup Guide for Rails Active Storage

This guide provides a detailed, step-by-step process for configuring Cloudflare to cache images served by a Rails application using Active Storage. This setup significantly reduces server load and AWS S3 egress costs.

## Strategy Overview

-   **Goal**: Cache images served via Rails proxy routes (`/rails/active_storage/*`) using Cloudflare.
-   **Method**: Rails serves the image from S3 on the first request (cache MISS). Cloudflare caches the response and serves all subsequent requests directly from its edge network (cache HIT).
-   **Benefit**: Fast image delivery for users, minimal load on your server, and dramatically lower S3 data transfer costs.

---

## Phase 1: Prerequisites & Server-Side Setup

This phase ensures your Rails application and server are ready for Cloudflare integration.

1.  **Confirm Rails Configuration**:
    -   `config/initializers/active_storage.rb`: Ensure `config.active_storage.resolve_model_to_route` is set to `:rails_storage_proxy`.
    -   `config/initializers/active_storage_cache_headers.rb`: Ensure this file exists and sets a long-lived `Cache-Control` header (e.g., `public, max-age=31536000, immutable`).

2.  **Enable SSL on Your Server (Kamal)**:
    -   In `config/deploy.yml`, ensure your proxy configuration enables SSL:
        ```yaml
        proxy:
          ssl: true
          host: bentobook.app
        ```

3.  **Deploy Changes**:
    -   Run `bin/kamal deploy` to apply the SSL configuration to your server. The `kamal-proxy` will automatically obtain a Let's Encrypt certificate.

---

## Phase 2: Cloudflare Configuration

Now, configure Cloudflare to handle your domain and cache the images.

1.  **Set SSL/TLS to Full (Strict)**:
    -   Navigate to **SSL/TLS** > **Overview** in your Cloudflare dashboard.
    -   Select **Full (strict)**. This ensures a secure connection from the user all the way to your origin server.

2.  **Enable Performance & Security Settings**:
    -   Navigate to **Speed** > **Optimization**.
    -   Ensure **Brotli** is enabled.
    -   Navigate to **Network**.
    -   Ensure **HTTP/2** and **HTTP/3** are enabled.

3.  **Create a Cache Rule for Active Storage**:
    -   Navigate to **Caching** > **Cache Rules**.
    -   Click **Create rule**.
    -   **Rule Name**: `Cache Rails Active Storage`
    -   **When incoming requests match...**:
        -   Use the **Custom filter expression** editor.
        -   Enter the following expression to target both original images and variants:
            `(starts_with(http.request.uri.path, "/rails/active_storage/proxy/")) or (starts_with(http.request.uri.path, "/rails/active_storage/representations/proxy/"))`
    -   **Then... (Cache settings)**:
        -   **Cache eligibility**: `Eligible for cache`
        -   **Edge TTL**: `Respect origin` (This will use the 1-year `max-age` header from your Rails app).
        -   **Browser TTL**: `Respect origin`
    -   Click **Deploy**.

---

## Phase 3: Validation

Verify that everything is working as expected.

1.  **Get an Image URL**: Find an image URL from your application's UI, or generate one in the Rails console:
    ```ruby
    # In `bin/rails c`
    u = Rails.application.routes.url_helpers
    img = Image.first # Or any model with an attached file
    url = u.rails_blob_url(img.file)
    puts url
    ```

2.  **Check Headers with `curl`**:
    -   Run the command twice from your terminal.
    -   **First Request (Expect a MISS)**:
        ```bash
        curl -I "PASTE_YOUR_IMAGE_URL_HERE"
        ```
        Look for `cf-cache-status: MISS`.
    -   **Second Request (Expect a HIT)**:
        ```bash
        curl -I "PASTE_YOUR_IMAGE_URL_HERE"
        ```
        Look for `cf-cache-status: HIT`.
    -   On both requests, verify the `cache-control` header is present: `cache-control: public, max-age=31536000, immutable`.

---

## Phase 4: Pre-processing & Monitoring

1.  **Generate Variants**: To avoid slow first loads, pre-process your common image variants on the server:
    ```bash
    RAILS_ENV=production bin/rails images:generate_variants
    ```

2.  **Monitor**: Keep an eye on two key metrics:
    -   **Cloudflare Analytics**: Check the cache hit ratio for your domain. It should increase significantly.
    -   **AWS Billing**: Monitor your S3 egress costs. They should drop dramatically.
