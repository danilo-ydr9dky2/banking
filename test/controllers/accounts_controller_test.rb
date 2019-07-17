require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "gets all accounts for user" do
    frankie = users(:frankie)
    get user_accounts_url(user_id: frankie.id), headers: auth_headers(frankie)
    assert_response(:success)

    account_ids = parsed_response[:accounts].map { |act| act[:id] }
    accounts(:frankie_a0, :frankie_a100, :frankie_a200).each do |account|
      assert_includes(account_ids, account.id)
    end
  end

  test "fails to get all accounts for another user" do
    frankie = users(:frankie)
    get user_accounts_url(user_id: frankie.id), headers: auth_headers(users(:norma))
    assert_response(:forbidden)
  end

  test "gets all accounts for user with no accounts" do
    accountless = users(:accountless)
    get user_accounts_url(user_id: accountless.id), headers: auth_headers(accountless)
    assert_response(:success)
    assert_empty(parsed_response[:accounts])
  end

  test "gets all accounts for non-existing user" do
    get user_accounts_url(user_id: not_found_user_id)
    assert_response(:unauthorized)
  end

  test "creates a new user and a new account" do
    post users_url, params: { name: "Test User", email: "test-123@email.com", password: "secret" }
    assert_response(:success)

    new_user = User.find_by(id: parsed_response[:id])
    assert_not_nil(new_user)

    post user_accounts_url(user_id: new_user.id), headers: auth_headers(new_user)
    assert_response(:success)
  end

  test "fails to create a new account for another user" do
    post user_accounts_url(user_id: users(:norma).id), headers: auth_headers(users(:frankie))
    assert_response(:forbidden)
  end

  test "fails to creates a new account for a non-existing user" do
    post user_accounts_url(user_id: not_found_user_id)
    assert_response(:unauthorized)
  end

  test "shows an existing account" do
    expected_account = accounts(:frankie_a100)
    get account_url(id: expected_account.id), headers: auth_headers(expected_account.user)
    assert_response(:success)
    assert_equal({
      id: expected_account.id,
      balance: expected_account.balance,
      user_id: expected_account.user_id
    }, parsed_response.except(:created_at, :updated_at))
  end

  test "fails to show an account of another user" do
    get account_url(id: accounts(:norma_a500).id), headers: auth_headers(users(:frankie))
    assert_response(:forbidden)
  end

  test "fails to show a non-existing account" do
    get account_url(id: not_found_account_id)
    assert_response(:unauthorized)
  end

  test "gets balance" do
    a100 = accounts(:frankie_a100)
    get account_balance_url(account_id: a100.id), headers: auth_headers(a100.user)
    assert_response(:success)
    assert_equal(100.0, parsed_response[:balance])
  end

  test "fails to get balance for another user's account" do
    get account_balance_url(account_id: accounts(:norma_a500).id), headers: auth_headers(users(:frankie))
    assert_response(:forbidden)
  end

  test "fails to get balance for a non-existing account" do
    get account_balance_url(account_id: not_found_account_id)
    assert_response(:unauthorized)
  end

  test "deletes account successfully" do
    a0 = accounts(:frankie_a0)
    delete account_url(id: a0.id), headers: auth_headers(a0.user)
    assert_response(:success)

    get account_url(id: a0.id), headers: auth_headers(a0.user)
    assert_response(:not_found)
  end

  test "fails to delete another user's account" do
    delete account_url(id: accounts(:norma_a500).id), headers: auth_headers(users(:frankie))
    assert_response(:forbidden)
  end

  test "fails to delete account for a non-existing account" do
    delete account_url(id: not_found_account_id)
    assert_response(:unauthorized)
  end

  test "transfer less than source account balance" do
    source, dest = accounts(:frankie_a100, :frankie_a0)
    post "/accounts/#{source.id}/transfer/#{dest.id}", params: { amount: 99.99 }, headers: auth_headers(source.user)
    assert_response(:success)

    get account_url(id: source.id), headers: auth_headers(source.user)
    assert_in_epsilon(0.01, parsed_response[:balance], 1e-6)

    get account_url(id: dest.id), headers: auth_headers(dest.user)
    assert_in_epsilon(99.99, parsed_response[:balance], 1e-6)
  end

  test "transfer amount equal to the source account balance" do
    source, dest = accounts(:frankie_a100, :frankie_a0)
    post "/accounts/#{source.id}/transfer/#{dest.id}", params: { amount: 100.0 }, headers: auth_headers(source.user)
    assert_response(:success)

    get account_url(id: source.id), headers: auth_headers(source.user)
    assert_in_epsilon(0.0, parsed_response[:balance], 1e-6)

    get account_url(id: dest.id), headers: auth_headers(dest.user)
    assert_in_epsilon(100.0, parsed_response[:balance], 1e-6)
  end

  test "transfer more than source account balance" do
    source, dest = accounts(:frankie_a100, :frankie_a0)
    post "/accounts/#{source.id}/transfer/#{dest.id}", params: { amount: 100.01 }, headers: auth_headers(source.user)
    assert_response(:forbidden)
    assert_match("insufficient funds", parsed_response[:errors].first)

    # source account's balance did not change
    get account_url(id: source.id), headers: auth_headers(source.user)
    assert_in_epsilon(source.balance, parsed_response[:balance], 1e-6)

    # destination account's balance did not change
    get account_url(id: dest.id), headers: auth_headers(dest.user)
    assert_in_epsilon(dest.balance, parsed_response[:balance], 1e-6)
  end

  test "fails to transfer logged in as destination account" do
    source, dest = accounts(:norma_a500, :frankie_a0)
    post "/accounts/#{source.id}/transfer/#{dest.id}", params: { amount: 1.00 }, headers: auth_headers(dest.user)
    assert_response(:forbidden)
  end
end
