ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails"
require "minitest/rails/capybara"
require "minitest/pride"
require 'capybara/poltergeist'

# VCR to playback HTTP responses without making actual connections
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = true
end

class ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
    ActionMailer::Base.deliveries.clear
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  ActiveRecord::Migration.check_pending!
end

class ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
end

class Capybara::Rails::TestCase
  include Warden::Test::Helpers
  Warden.test_mode!
  Capybara.javascript_driver = :poltergeist

  def teardown
    Warden.test_reset!
  end
end
require 'minitest/unit'
require 'mocha/mini_test'
