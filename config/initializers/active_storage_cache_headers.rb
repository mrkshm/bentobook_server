# Sets long-lived caching headers for Active Storage responses so Cloudflare can cache them.
# We only apply this in production and only to /rails/active_storage/* paths.

if Rails.env.production?
  class ActiveStorageCacheHeaders
    ONE_YEAR = 365 * 24 * 60 * 60

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      if env["PATH_INFO"].start_with?("/rails/active_storage/")
        headers["Cache-Control"] = "public, max-age=#{ONE_YEAR}, immutable"
      end

      [status, headers, body]
    end
  end

  Rails.application.config.middleware.insert_after ActionDispatch::Static, ActiveStorageCacheHeaders
end
