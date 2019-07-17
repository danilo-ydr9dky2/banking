require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "Frankie's account balances" do
    assert_equal("0,00", accounts(:frankie_a0).balance)
    assert_equal(0, accounts(:frankie_a0).balance_in_cents)

    assert_equal("100,00", accounts(:frankie_a100).balance)
    assert_equal(10000, accounts(:frankie_a100).balance_in_cents)

    assert_equal("200,00", accounts(:frankie_a200).balance)
    assert_equal(20000, accounts(:frankie_a200).balance_in_cents)
  end

  test "Frankie's account ownership" do
    accounts(:frankie_a0, :frankie_a100, :frankie_a200).each do |account|
      assert_equal(users(:frankie), account.user)
    end
  end

  test "Norma's account balances" do
    assert_equal("9,01", accounts(:norma_a901).balance)
    assert_equal(901, accounts(:norma_a901).balance_in_cents)

    assert_equal("99,99", accounts(:norma_a9999).balance)
    assert_equal(9999, accounts(:norma_a9999).balance_in_cents)

    assert_equal("500,00", accounts(:norma_a500).balance)
    assert_equal(50000, accounts(:norma_a500).balance_in_cents)
  end

  test "Norma's account ownership" do
    assert_equal(users(:norma), accounts(:norma_a500).user)
  end
end
