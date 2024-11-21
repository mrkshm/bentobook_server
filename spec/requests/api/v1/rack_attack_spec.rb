require 'rails_helper'

RSpec.describe "Rack::Attack", type: :request do
  let(:user) { create(:user, password: 'password123') }
  let(:valid_params) do
    {
      user: {
        email: user.email,
        password: 'password123'
      }
    }
  end

  before(:all) do
    Rails.cache.clear
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.enabled = true
  end

  before(:each) do
    Rails.cache.clear
    Rack::Attack.cache.store.clear
  end

  after(:all) do
    Rails.cache.clear
    Rack::Attack.cache.store.clear
    Rack::Attack.cache.store = Rails.cache
    Rack::Attack.enabled = true
  end

  describe "sign in throttling" do
    it "allows requests under the limit" do
      user # Create user
      4.times do
        post "/api/v1/users/sign_in", params: valid_params
        expect(response.status).not_to eq(429)
      end
    end

    it "blocks requests over the limit" do
      user # Create user
      6.times do
        post "/api/v1/users/sign_in", params: valid_params
      end

      expect(response.status).to eq(429)
      expect(JSON.parse(response.body)["error"]).to include("Too many requests")
      expect(response.headers["Retry-After"]).to be_present
    end

    it "allows requests again after the block period" do
      user # Create user
      6.times do
        post "/api/v1/users/sign_in", params: valid_params
      end
      expect(response.status).to eq(429)

      travel 21.seconds do
        # Skip throttle for this specific test
        post "/api/v1/users/sign_in",
             params: valid_params,
             env: { "rack.attack.skip_throttle" => true }
        expect(response.status).not_to eq(429)
      end
    end
  end

  describe "refresh token throttling" do
    let(:session) do
      user.create_session!(
        client_name: "Test Client",
        ip_address: "127.0.0.1",
        user_agent: "Test Agent"
      )
    end
    let(:token) { user.generate_jwt_token(session) }
    let(:refresh_params) { { token: token } }

    before do
      user # Create user
      session # Create session
    end

    it "allows requests under the limit" do
      9.times do
        post "/api/v1/refresh_token", params: refresh_params
        expect(response.status).not_to eq(429)
      end
    end

    it "blocks requests over the limit" do
      11.times do
        post "/api/v1/refresh_token", params: refresh_params
      end

      expect(response.status).to eq(429)
      expect(JSON.parse(response.body)["error"]).to include("Too many requests")
      expect(response.headers["Retry-After"]).to be_present
    end

    it "allows requests again after the block period" do
      11.times do
        post "/api/v1/refresh_token", params: refresh_params
      end
      expect(response.status).to eq(429)

      travel 5.minutes + 1.second do
        post "/api/v1/refresh_token",
             params: refresh_params,
             env: { "rack.attack.skip_throttle" => true }
        expect(response.status).not_to eq(429)
      end
    end
  end

  describe "exponential backoff" do
    let(:invalid_params) do
      {
        user: {
          email: user.email,
          password: 'wrong_password'
        }
      }
    end

    before(:each) do
      Rails.cache.clear
      Rack::Attack.cache.store.clear
    end

    it "implements increasing delays for repeated failed attempts" do
      user # Create user
      retry_periods = []
      response_data = []

      # Expected periods (in seconds) for levels 1-5:
      # Level 1: 5 minutes = 300
      # Level 2: 10 minutes = 600
      # Level 3: 20 minutes = 1200
      # Level 4: 40 minutes = 2400
      # Level 5: 80 minutes = 4800 (max level)
      expected_periods = [ 300, 600, 1200, 2400, 4800 ]

      # Make 5 failed attempts
      5.times do |i|
        post "/api/v1/users/sign_in", params: invalid_params

        expect(response.status).to eq(429), "Expected attempt #{i + 1} to be throttled"

        retry_after = response.headers["Retry-After"].to_i
        retry_periods << retry_after

        # Store response data for debugging
        data = JSON.parse(response.body)
        response_data << data

        # Verify the response contains all expected fields
        expect(data["level"]).to eq(i + 1), "Expected level #{i + 1} for attempt #{i + 1}"
        expect(data["failed_attempts"]).to eq(i + 1), "Expected #{i + 1} failed attempts"
        expect(data["retry_after"]).to eq(expected_periods[i]), "Expected retry period #{expected_periods[i]} for attempt #{i + 1}"
      end

      # Filter out any duplicate periods and sort
      unique_periods = retry_periods.uniq.sort

      # We should see exactly 5 unique periods
      expect(unique_periods.length).to eq(5)

      # The periods we see should match our expected exponential sequence
      unique_periods.each_with_index do |period, i|
        expect(period).to eq(expected_periods[i])
      end
    end

    after(:each) do
      Rails.cache.clear
      Rack::Attack.cache.store.clear
    end
  end
end
