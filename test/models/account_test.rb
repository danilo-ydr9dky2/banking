require 'test_helper'

class AccountTest < ActiveSupport::TestCase
    test "accounts count" do
        assert_equal 2, Account.count
    end

    test "account one" do
        assert_equal 100.0, accounts(:one).balance
    end

    test "account two" do
        assert_equal 200.0, accounts(:two).balance
    end
end
