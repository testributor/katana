ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails"
require "minitest/rails/capybara"
require "minitest/pride"
require 'capybara/poltergeist'
# VCR to playback HTTP responses without making actual connections
require 'vcr'
# Cleanup database between tests (Only for JS tests)
require 'database_cleaner'
require 'sidekiq/testing'

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = true
end

class ActionController::TestCase
  include Devise::TestHelpers

  def setup
    # Stub create_webhooks! in order to disable external
    # requests
    Project.any_instance.stubs(:create_webhooks!).returns(1)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    ActionMailer::Base.deliveries.clear
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  ActiveRecord::Migration.check_pending!
  Sidekiq::Testing.inline!
end

class ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
end

class Capybara::Rails::TestCase
  include Warden::Test::Helpers

  Warden.test_mode!
  Capybara.javascript_driver = :poltergeist

  # Transactional fixtures do not work with Selenium tests, because Capybara
  # # uses a separate server thread, which the transactions would be hidden
  # from. We hence use DatabaseCleaner to truncate our test database.
  # @see http://stackoverflow.com/questions/10904996/difference-between-truncation-transaction-and-deletion-database-strategies
  self.use_transactional_fixtures = false

  before do
    # Stub create_webhooks! in order to disable external
    # requests
    Project.any_instance.stubs(:create_webhooks!).returns(1)
    # No javascript tests
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    else # Javascript tests
      # @see http://stackoverflow.com/questions/10904996/difference-between-truncation-transaction-and-deletion-database-strategies
      DatabaseCleaner.strategy = :deletion
    end
  end

  def teardown
    DatabaseCleaner.clean
    Warden.test_reset!
  end
end
require 'minitest/unit'
require 'mocha/mini_test'

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
  :provider => 'github',
  :uid => '123545',
  :info => {
    :email => 'spyros@github.com'
  }
})

if ENV['RUBYMINE']
  require 'minitest/reporters'
  reporters = [Minitest::Reporters::RubyMineReporter.new]
  MiniTest::Reporters.use!(reporters)
end
