require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "gets all accounts for user" do
    get user_accounts_url(user_id: users(:frankie).id)
    assert_response(:success)

    account_ids = parsed_response[:accounts].map { |act| act[:id] }
    accounts(:frankie_a0, :frankie_a100, :frankie_a200).each do |account|
      assert_includes(account_ids, account.id)
    end
  end

  test "gets all accounts for user with no accounts" do
    get user_accounts_url(user_id: users(:accountless).id)
    assert_response(:success)
    assert_empty(parsed_response[:accounts])
  end

  test "gets all accounts for non-existing user" do
    get user_accounts_url(user_id: not_found_user_id)
    assert_response(:not_found)
  end

  test "creates a new user and a new account" do
    post users_url, params: { name: "Test User", email: "test-123@email.com", password: "secret" }
    assert_response(:success)

    new_user_id = parsed_response[:id]
    assert_not_nil(new_user_id)

    post user_accounts_url(user_id: new_user_id)
    assert_response(:success)
  end

  test "creates a new account within a non-existing user" do
    post user_accounts_url(user_id: not_found_user_id)
    assert_response(:not_found)
  end

  test "shows an existing account" do
    expected_account = accounts(:frankie_a100)
    get account_url(id: expected_account.id)
    assert_response(:success)
    assert_equal({
      id: expected_account.id,
      balance: expected_account.balance,
      user_id: expected_account.user_id
    }, parsed_response.except(:created_at, :updated_at))
  end

  test "shows a non-existing account" do
    get account_url(id: not_found_account_id)
    assert_response(:not_found)
  end

  test "gets balance" do
    get account_balance_url(account_id: accounts(:frankie_a100).id)
    assert_response(:success)
    assert_equal(100.0, parsed_response[:balance])
  end

  test "gets balance for non-existing account" do
    get account_balance_url(account_id: not_found_account_id)
    assert_response(:not_found)
  end

  test "deletes account successfully" do
    delete account_url(id: accounts(:frankie_a0).id)
    assert_response(:success)

    get account_url(id: accounts(:frankie_a0).id)
    assert_response(:not_found)
  end

  test "deletes account for non-existing account" do
    delete account_url(id: not_found_account_id)
    assert_response(:not_found)
  end

  test "transfer less than source account balance" do
    source, dest = accounts(:frankie_a100, :frankie_a0)
    post "/accounts/#{source.id}/transfer/#{dest.id}", params: { amount: 99.99 }
    assert_response(:success)

    get account_url(id: source.id)
    assert_in_epsilon(0.01, parsed_response[:balance], 1e-6)

    get account_url(id: dest.id)
    assert_in_epsilon(99.99, parsed_response[:balance], 1e-6)
  end

  test "transfer amount equal to the source account balance" do
    source, dest = accounts(:frankie_a100, :frankie_a0)
    post "/accounts/#{source.id}/transfer/#{dest.id}", params: { amount: 100.0 }
    assert_response(:success)

    get account_url(id: source.id)
    assert_in_epsilon(0.0, parsed_response[:balance], 1e-6)

    get account_url(id: dest.id)
    assert_in_epsilon(100.0, parsed_response[:balance], 1e-6)
  end

  test "transfer more than source account balance" do
    source, dest = accounts(:frankie_a100, :frankie_a0)
    post "/accounts/#{source.id}/transfer/#{dest.id}", params: { amount: 100.01 }
    assert_response(:forbidden)
    assert_match("insufficient funds", parsed_response[:errors].first)

    # source account's balance did not change
    get account_url(id: source.id)
    assert_in_epsilon(source.balance, parsed_response[:balance], 1e-6)

    # destination account's balance did not change
    get account_url(id: dest.id)
    assert_in_epsilon(dest.balance, parsed_response[:balance], 1e-6)
  end
end
