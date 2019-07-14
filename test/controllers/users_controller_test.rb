require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "should create a new user" do
    post users_url, params: { name: "George", email: "george@email.com", password: "secret" }
    assert_response :success
  end

  test "fails to create user with empty fields" do
    post users_url, params: { name: "", email: "", password: "" }
    assert_response :bad_request
    gotten = response.parsed_body.deep_symbolize_keys
    [:name, :email, :password].each do |field|
        assert_match("can't be blank", gotten[:errors][field].first)
    end
  end

  test "fails to create user with invalid email" do
    post users_url, params: { name: "George", email: "randomstring", password: "secret" }
    assert_response :bad_request
    gotten = response.parsed_body.deep_symbolize_keys
    assert_match("is invalid", gotten[:errors][:email].first)

  end

  test "fails to create user with invalid password" do
    post users_url, params: { name: "George", email: "george@email.com", password: "short" }
    assert_response :bad_request
    gotten = response.parsed_body.deep_symbolize_keys
    assert_match("too short", gotten[:errors][:password].first)
  end

  test "should get user Frankie" do
    frankie = users(:frankie)
    get user_url(id: frankie.id)
    assert_response :success
    gotten = response.parsed_body.symbolize_keys.except(:created_at, :updated_at)
    assert_equal({id: frankie.id, name: frankie.name, email: frankie.email }, gotten)
  end

  test "user not found" do
      get user_url(id: 999)
      assert_response :not_found
  end

  test "should delete user with no accounts" do
    user = users(:accountless)

    # deletes user with no accounts
    delete user_url(id: user.id)
    assert_response :success

    # user can't be found anymore
    get user_url(id: user.id)
    assert_response :not_found
  end

end
