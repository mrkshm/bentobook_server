# CLAUDE.md - BentoBook Development Guidelines

## Build / Test / Lint Commands
- Run server: `bin/dev`
- Build frontend: `bun run vite build`
- Run all tests: `bin/rails spec`
- Run single test: `bin/rails spec SPEC=spec/path/to_spec.rb:LINE_NUMBER`
- Run system tests: `bin/rails spec:system`
- Linting: `bin/rubocop`
- Security check: `bin/brakeman`

## Code Style Guidelines
- Use Rails 8 conventions and Ruby idioms
- Frontend located in app/frontend/ (not app/javascript/)
- Use Tailwind 4 for styling with color variables from app/frontend/stylesheets/application.css
- Constructor paths format: `restaurant_path(id: restaurant.id, locale: current_locale)` instead of `restaurant_path(restaurant)`
- Write readable, maintainable code over performance optimizations
- Use ViewComponent for UI components
- Follow Rubocop-Rails-Omakase styles
- No TODOs or placeholder code in PRs - fully implement all functionality
- Prioritize clear error handling and type safety
- Ensure all code is secure and follows best practices