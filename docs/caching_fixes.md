# Caching and Turbo Drive Fixes

## Problem: Stale Data in Native App

When updating ratings in the native app using Hotwire/Turbo Drive, sometimes the old data would still be visible, requiring a manual refresh to see updates. This was due to aggressive caching in the Turbo Drive adapter used in the native app.

## Solution Components

### 1. Cache Control Headers

Added strong cache control headers to force browsers/clients not to use cached content:

```ruby
# In controller actions that modify data
response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
response.headers["Pragma"] = "no-cache"
response.headers["Expires"] = "0"
```

### 2. Timestamp Parameters

Added timestamp parameters to URLs to bust caches:

```ruby
# When redirecting after updates
timestamp = Time.current.to_i
redirect_url = restaurant_path(id: @restaurant.id, locale: current_locale, t: timestamp)
```

### 3. Form Configuration

Updated form submission behavior:

```erb
<%= form_with model: @restaurant, 
  url: restaurant_rating_path(restaurant_id: @restaurant.id, locale: current_locale, t: timestamp),
  data: { 
    turbo_frame: hotwire_native_app? ? "_top" : dom_id(@restaurant, :rating),
    turbo_action: hotwire_native_app? ? "replace" : nil
  },
  method: :patch,
  class: "bg-white rounded-lg shadow p-4" do |f| %>
```

### 4. Full Page Replacements

For native app, used full page replacements instead of frame updates:

```ruby
# In controller
if hotwire_native_app?
  redirect_to redirect_url, 
    data: { turbo_action: "replace", turbo_frame: "_top" }
else
  render turbo_stream: turbo_stream.replace(...)
end
```

## Key Insights

1. **Browser/Native App Differences**: Mobile apps using Turbo Native often need different caching strategies than web browsers.

2. **Cache-Busting Techniques**: Using timestamps in URLs is an effective way to prevent cached responses.

3. **Header Controls**: HTTP cache control headers provide a standardized way to prevent caching.

4. **Full Page Replacement**: For native apps, replacing the entire page (`turbo_frame: "_top"`) is more reliable than individual frame updates.

5. **Form Configuration**: Adding cache control properties to form submissions helps ensure fresh data is used.

## Applicable Areas

This approach is helpful for any feature where immediate updates are critical:
- Ratings
- Form submissions
- Any user interaction that modifies data and should be immediately visible

## Testing Recommendations

When implementing similar caching controls:
1. Test in both web and native app environments
2. Verify with network throttling enabled to simulate slower connections
3. Check that updates are visible without manual refresh