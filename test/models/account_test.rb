require 'test_helper'

class AccountTest < ActiveSupport::TestCase
    test "Frankie's account balances" do
        assert_equal 0, accounts(:frankie_a0).balance
        assert_equal 100, accounts(:frankie_a100).balance
        assert_equal 200, accounts(:frankie_a200).balance
    end

    test "Frankie's account ownership" do
        accounts(:frankie_a0, :frankie_a100, :frankie_a200).each do |account|
            assert_equal users(:frankie), account.user
        end
    end

    test "Norma's account balance" do
        assert_equal 500, accounts(:norma_a500).balance
    end

    test "Norma's account ownership" do
        assert_equal users(:norma), accounts(:norma_a500).user
    end
end
