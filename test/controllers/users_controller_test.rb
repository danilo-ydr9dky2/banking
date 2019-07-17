require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "should create a new user" do
    post users_url, params: { name: "George", email: "george@email.com", password: "secret" }
    assert_response :success
  end

  test "fails to create user with empty name" do
    post users_url, params: { name: "", email: "george@email.com", password: "secret" }
    assert_response :bad_request
    assert_match("can't be blank", parsed_response[:errors][:name].first)
  end

  test "fails to create user with invalid email" do
    post users_url, params: { name: "George", email: "randomstring", password: "secret" }
    assert_response :bad_request
    assert_match("is invalid", parsed_response[:errors][:email].first)
  end

  test "fails to create user with repeated email" do
    # the first request is successful
    post users_url, params: { name: "George", email: "george@email.com", password: "secret" }
    assert_response :success

    # the second one is not
    post users_url, params: { name: "Another George", email: "george@email.com", password: "secret" }
    assert_response :bad_request
    assert_match("email is already taken", parsed_response[:errors][:email].first)
  end

  test "fails to create user with invalid password" do
    post users_url, params: { name: "George", email: "george@email.com", password: "short" }
    assert_response :bad_request
    assert_match("too short", parsed_response[:errors][:password].first)
  end

  test "should get user Frankie" do
    frankie = users(:frankie)
    get user_url(id: frankie.id), headers: auth_headers(frankie)
    assert_response :success
    gotten = parsed_response.except(:created_at, :updated_at)
    assert_equal({id: frankie.id, name: frankie.name, email: frankie.email }, gotten)
  end

  test "should get 403 when showing another user" do
    get user_url(id: users(:frankie).id), headers: auth_headers(users(:norma))
    assert_response :forbidden
  end

  test "user not found" do
    get user_url(id: not_found_user_id), headers: auth_headers(users(:frankie))
    assert_response :not_found
  end

  test "should delete user with no accounts" do
    user = users(:accountless)

    # deletes user with no accounts
    delete user_url(id: user.id), headers: auth_headers(user)
    assert_response :success

    # user can't be found anymore
    get user_url(id: user.id), headers: auth_headers(user)
    # it returns a 401 as the logged in user cannot be found
    assert_response :unauthorized
  end

  test "should get 403 when deleting another user" do
    delete user_url(id: users(:accountless).id), headers: auth_headers(users(:frankie))
    assert_response :forbidden
  end
end
