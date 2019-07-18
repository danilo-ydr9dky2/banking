require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "signs in successfully as new user" do
    post users_url, params: { name: "Alice", email: "alice@email.com", password: "secret" }
    assert_response :success

    post user_session_url, params: { user: { email: "alice@email.com", password: "secret" } }
    assert_response :success
    assert_match("Bearer", response.headers["Authorization"])
  end

  test "fails to sign in with incorrect email" do
    post users_url, params: { name: "Alice", email: "alice@email.com", password: "secret" }
    assert_response :success

    post user_session_url, params: { user: { email: "bob@email.com", password: "secret" } }
    assert_response :unauthorized
  end

  test "fails to sign in with incorrect password" do
    post users_url, params: { name: "Alice", email: "alice@email.com", password: "secret" }
    assert_response :success

    post user_session_url, params: { user: { email: "alice@email.com", password: "wrong" } }
    assert_response :unauthorized
  end

  test "signs out successfully" do
    delete destroy_user_session_url, headers: auth_headers(users(:frankie))
    assert_response :success
    assert_nil(response.headers["Authorization"])
  end
end
