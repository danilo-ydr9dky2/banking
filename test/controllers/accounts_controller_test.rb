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
    get user_account_url(user_id: expected_account.user_id, id: expected_account.id)
    assert_response(:success)
    assert_equal({
      id: expected_account.id,
      balance: expected_account.balance,
      user_id: expected_account.user_id
    }, parsed_response.except(:created_at, :updated_at))
  end

  test "shows an account for a non-existing user" do
    get user_account_url(user_id: not_found_user_id, id: accounts(:frankie_a0).id)
    assert_response(:not_found)
  end

  test "shows a non-existing account" do
    get user_account_url(user_id: users(:frankie).id, id: not_found_account_id)
    assert_response(:not_found)
  end

  test "shows an account for an existing but incorrect user" do
    get user_account_url(user_id: users(:frankie).id, id: accounts(:norma_a500).id)
    assert_response(:not_found)
  end

  test "gets balance" do
    get user_account_balance_url(user_id: users(:frankie).id, account_id: accounts(:frankie_a100).id)
    assert_response(:success)
    assert_equal(100.0, parsed_response[:balance])
  end

  test "gets balance for non-existing user" do
    get user_account_balance_url(user_id: not_found_user_id, account_id: accounts(:frankie_a100).id)
    assert_response(:not_found)
  end

  test "gets balance for non-existing account" do
    get user_account_balance_url(user_id: users(:frankie).id, account_id: not_found_account_id)
    assert_response(:not_found)
  end

  test "gets balance for existing but incorrect user" do
    get user_account_balance_url(user_id: users(:frankie).id, account_id: accounts(:norma_a500).id)
    assert_response(:not_found)
  end

  test "deletes account successfully" do
    delete user_account_url(user_id: users(:frankie).id, id: accounts(:frankie_a0).id)
    assert_response(:success)

    get user_account_url(user_id: users(:frankie).id, id: accounts(:frankie_a0).id)
    assert_response(:not_found)
  end

  test "deletes account for non-existing user" do
    delete user_account_url(user_id: not_found_user_id, id: accounts(:frankie_a0).id)
    assert_response(:not_found)
  end

  test "deletes account for non-existing account" do
    delete user_account_url(user_id: users(:frankie).id, id: not_found_account_id)
    assert_response(:not_found)
  end

  test "deletes account for existing but incorrect user" do
    delete user_account_url(user_id: users(:frankie).id, id: accounts(:norma_a500).id)
    assert_response(:not_found)
  end
end
