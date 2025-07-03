# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.2
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
RUN apt-get update && apt-get install -y libyaml-dev && \
    rm -rf /var/lib/apt/lists/* && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# (Removed Bun installation – no asset build needed)








# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Ensure any change to production config busts the cache for the next layer
COPY config/environments/production.rb ./config/environments/production.rb



# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 \
    DEVISE_JWT_SECRET_KEY=dummy_key_for_asset_compilation \
    RAILS_ENV=production \
    ./bin/rails assets:precompile

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
