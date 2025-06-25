# CLAUDE.md - BentoBook Development Guidelines

## Build / Test / Lint Commands
- Run server: `bin/dev`
- Linting: `bin/rubocop`

This was formerly build with Vite, now we are switching to a no-build app with importmaps.

## Importmap Setup Issue & Fix
**Problem**: After switching from Vite to importmaps, got "Importmap skipped missing path" errors for all @hotwired and @rails packages, and stimulus controllers weren't working.

**Root Cause**: The importmap configuration was corrupted/incomplete after the Vite migration. The vendor/javascript files existed but weren't properly configured in importmap.rb.

**Solution**: 
1. Run `bin/rails importmap:install` to reset importmap configuration
2. Add vendor/javascript to Rails asset paths in `config/initializers/assets.rb`:
   ```ruby
   Rails.application.config.assets.paths << Rails.root.join("vendor", "javascript")
   ```
3. Re-pin all required packages:
   ```bash
   ./bin/importmap pin @hotwired/stimulus @hotwired/turbo-rails @hotwired/turbo @rails/actioncable @hotwired/hotwire-native-bridge @rails/actioncable/src
   ```
4. Restore application.js imports:
   ```javascript
   import "@hotwired/turbo-rails"
   import "controllers"
   ```

After this fix, stimulus controllers work properly and no more missing path errors.

## Code Style Guidelines
- Use Rails 8 conventions and Ruby idioms
- Use Tailwind 4 for styling with color variables from app/frontend/stylesheets/application.css
- Constructor paths format: `restaurant_path(id: restaurant.id, locale: current_locale)` instead of `restaurant_path(restaurant)`
- Write readable, maintainable code over performance optimizations
- Use ViewComponent for UI components
- Follow Rubocop-Rails-Omakase styles