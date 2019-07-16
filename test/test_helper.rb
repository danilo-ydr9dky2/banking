ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def parsed_response
    response.parsed_body.deep_symbolize_keys
  end

  # It assumes there is no such user id in test/fixtures/users.yml
  # FIXME: this could break in case that is no longer true
  def not_found_user_id
    999
  end

  # It assumes there is no such user id in test/fixtures/accounts.yml
  # FIXME: this could break in case that is no longer true
  def not_found_account_id
    999
  end
end
