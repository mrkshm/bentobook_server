# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base packages including PostGIS runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client \
    netcat-openbsd \
    postgis \
    libgeos-c1v5 \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    RAILS_SERVE_STATIC_FILES="true"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and assets
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    pkg-config \
    unzip \
    curl \
    libgeos-dev \
    libproj-dev \
    libgdal-dev \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# (Removed Bun installation – no asset build needed)








# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Ensure any change to production config busts the cache for the next layer
COPY config/environments/production.rb ./config/environments/production.rb



# Force a rebuild of the assets layer on every build (pass --build-arg ASSETS_REV=$(date +%s))
ARG ASSETS_REV=1750958000
ENV ASSETS_REV=${ASSETS_REV}

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# Fix CSS truncation by copying complete CSS after normal build
RUN SECRET_KEY_BASE_DUMMY=1 \
    DEVISE_JWT_SECRET_KEY=dummy_key_for_asset_compilation \
    RAILS_ENV=production \
    ./bin/rails assets:precompile

# Copy complete CSS over truncated version
RUN COMPLETE_CSS_SIZE=$(wc -c < /rails/app/assets/builds/tailwind.css) && \
    echo "Complete CSS size: $COMPLETE_CSS_SIZE bytes" && \
    for css_file in /rails/public/assets/tailwind-*.css; do \
        CURRENT_SIZE=$(wc -c < "$css_file") && \
        echo "Current CSS size: $CURRENT_SIZE bytes" && \
        if [ "$CURRENT_SIZE" -lt 50000 ]; then \
            echo "Replacing truncated CSS with complete version" && \
            cp /rails/app/assets/builds/tailwind.css "$css_file" && \
            echo "✅ CSS fix applied: $(wc -c < "$css_file") bytes"; \
        else \
            echo "✅ CSS file already complete: $CURRENT_SIZE bytes"; \
        fi; \
    done

# Final stage for app image
FROM base

ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_LOG_TO_STDOUT="true"

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails


# Create and set up the rails user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
