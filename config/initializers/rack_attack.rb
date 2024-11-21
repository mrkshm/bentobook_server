class Rack::Attack
  ### Configure Cache ###
  Rack::Attack.cache.store = Rails.cache

  ### Rate Limit API endpoints ###

  # Skip throttling in test environment unless explicitly enabled
  unless Rails.env.test?
    # Throttle refresh token attempts
    throttle("refresh_token/ip", limit: 10, period: 5.minutes) do |req|
      if req.path == "/api/v1/refresh_token" && req.post?
        req.ip
      end
    end

    # Throttle sign in attempts
    throttle("sign_in/ip", limit: 5, period: 20.seconds) do |req|
      if req.path == "/api/v1/users/sign_in" && req.post?
        req.ip
      end
    end

    # Exponential backoff for repeated failed auth attempts
    throttle("login/ip/fail2ban", limit: 1, period: 1.second) do |req|
      if req.path == "/api/v1/users/sign_in" && req.post? && req.env["rack.attack.matched"]
        key = "fail2ban:#{req.ip}"
        count = Rails.cache.increment(key, 1, expires_in: 1.hour).to_i

        # Calculate the backoff level (1-based)
        level = [ count, 6 ].min
        period = (300 * (2 ** (level - 1))) # 5 minutes * 2^(level-1)

        req.env["rack.attack.current_level"] = level
        req.env["rack.attack.period"] = period
        req.ip
      end
    end
  end

  ### Test environment specific throttling ###
  if Rails.env.test?
    # Basic sign in throttling - 5 requests per 20 seconds
    throttle("test/sign_in/basic", limit: 5, period: 20.seconds) do |req|
      if req.path == "/api/v1/users/sign_in" && req.post?
        "test:signin:basic"
      end
    end

    # Refresh token throttling - 10 requests per 5 minutes
    throttle("test/refresh_token/basic", limit: 10, period: 5.minutes) do |req|
      if req.path == "/api/v1/refresh_token" && req.post?
        "test:refresh:basic"
      end
    end

    # Exponential backoff for failed attempts
    throttle("test/login/fail2ban", limit: 0, period: 1.second) do |req|
      if req.path == "/api/v1/users/sign_in" && req.post?
        if req.params.dig("user", "password") == "wrong_password"
          key = "test:fail2ban:count"
          count = Rack::Attack.cache.count(key, 1.hour)

          # Set level equal to count (1-based)
          level = count
          period = (300 * (2 ** (level - 1))) # 5 minutes * 2^(level-1)

          # Store values in request env
          req.env["rack.attack.is_fail2ban"] = true
          req.env["rack.attack.current_level"] = level
          req.env["rack.attack.failed_count"] = count
          req.env["rack.attack.period"] = period

          true
        end
      end
    end
  end

  ### Custom error response ###
  Rack::Attack.throttled_responder = ->(request) {
    match_data = request.env["rack.attack.match_data"] || {}
    now = match_data[:epoch_time] || Time.now.to_i
    if request.env["rack.attack.is_fail2ban"]
      period = request.env["rack.attack.period"]
      level = request.env["rack.attack.current_level"]
      count = request.env["rack.attack.failed_count"]
    else
      period = match_data[:period]
      level = 0
      count = 0
    end
    period ||= 300
    level ||= 0
    count ||= 0
    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => period.to_s
    }
    body = {
      error: "Too many requests. Please try again later.",
      retry_after: period,
      level: level,
      failed_attempts: count,
      period: period
    }
    [ 429, headers, [ body.to_json ] ]
  }
end
