require 'simplecov'

SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/spec/'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# Prevent database truncation if the environment is running in production mode
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/7-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ActionDispatch::TestProcess
  config.include ActiveSupport::Testing::FileFixtures
  config.include ViewComponent::TestHelpers, type: :component
  config.include ActionView::Helpers::FormHelper
  config.include ActionView::RecordIdentifier
  config.include ActionDispatch::Routing::PolymorphicRoutes
  config.include AuthHelpers, type: :request
  config.include Warden::Test::Helpers

  # If you're using DatabaseCleaner, make sure to clean the test database after each test
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    # Clean up Active Storage blobs and attachments before suite
    FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))

    # Add PostGIS setup
    ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS postgis;")
    ActiveRecord::Base.connection.execute(<<-SQL)
      INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) 
      VALUES (4326, 'EPSG', 4326, 
        '+proj=longlat +datum=WGS84 +no_defs', 
        'GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]]')
      ON CONFLICT (srid) DO NOTHING;
    SQL

    # Configure Active Storage to use the test service
    ActiveStorage::Current.url_options = { host: "localhost:3000" }
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    # Clean up Active Storage test files after each test
    ActiveStorage::Blob.all.each(&:purge)
  end

  config.before(:each) do
    class << Rails.logger
      def debug_messages
        @debug_messages ||= []
      end

      def debug(message = nil)
        debug_messages << message if message
      end
    end
  end

  config.after(:each) do
    Rails.logger.debug_messages.clear if Rails.logger.respond_to?(:debug_messages)
  end
  DatabaseCleaner.clean
  ActiveStorage::Blob.unattached.find_each(&:purge)
  FileUtils.rm_rf(Dir["#{Rails.root}/tmp/storage/*"])
  RSpec::Mocks.space.reset_all
end

require 'shoulda/matchers'
require 'rails-controller-testing'
require 'timecop'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'coordinates'  => [40.7143528, -74.0059731],
      'address'      => 'New York, NY, USA',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)

Geocoder::Lookup::Test.add_stub(
  [40.7300, -74.0000], [
    {
      'coordinates'  => [40.7300, -74.0000],
      'address'      => 'New York, NY, USA',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)

Geocoder::Lookup::Test.add_stub(
  [40.7128, -74.0060], [
    {
      'coordinates'  => [40.7128, -74.0060],
      'address'      => 'New York, NY, USA',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)

Geocoder::Lookup::Test.add_stub(
  [40.7489, -73.9680], [
    {
      'coordinates'  => [40.7489, -73.9680],
      'address'      => 'New York, NY, USA',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)


def exceed_query_limit(limit)
  raise_error(RSpec::Expectations::ExpectationNotMetError) do |error|
    query_count = ActiveRecord::QueryCounter.count { yield }
    error.message = "Expected to run maximum #{limit} queries, but ran #{query_count}"
    query_count > limit
  end
end
