Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In development, we'll allow localhost
    origins 'localhost:3000', '127.0.0.1:3000', 'localhost:5173', '127.0.0.1:5173'

    resource '*',
      headers: :any,
      expose: ['Authorization'],  # This exposes the JWT token header
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
