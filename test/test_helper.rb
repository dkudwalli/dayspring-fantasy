ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    include ActiveJob::TestHelper

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    setup do
      auth_rate_limit_store.clear if auth_rate_limit_store.respond_to?(:clear)
    end

    # Add more helper methods to be used by all tests here...

    private

    def auth_rate_limit_store
      Rails.application.config.x.auth_rate_limit_store
    end
  end
end

class ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def sign_in_as(user, password: "password123")
    post session_path, params: {
      email: user.email,
      password: password
    }
  end
end
