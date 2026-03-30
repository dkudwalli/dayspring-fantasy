require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  test "user can log in and log out" do
    post session_path, params: {
      email: "  MEMBER@DAYSPRINGLABS.COM ",
      password: "password123"
    }

    assert_redirected_to root_path
    follow_redirect!
    assert_match users(:member).email, response.body

    delete session_path

    assert_redirected_to root_path
    follow_redirect!
    assert_match "You have been logged out.", response.body
  end

  test "user is redirected back to the protected page after logging in" do
    get prediction_history_path

    assert_redirected_to new_session_path

    post session_path, params: {
      email: users(:member).email,
      password: "password123"
    }

    assert_redirected_to prediction_history_url
  end

  test "invalid credentials re-render the form" do
    post session_path, params: {
      email: users(:member).email,
      password: "wrong-password"
    }

    assert_response :unprocessable_content
    assert_match "Invalid email or password.", response.body
  end

  test "login attempts are rate limited" do
    10.times do
      post session_path, params: {
        email: users(:member).email,
        password: "wrong-password"
      }

      assert_response :unprocessable_content
    end

    post session_path, params: {
      email: users(:member).email,
      password: "wrong-password"
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "Too many login attempts. Try again later.", response.body
  end
end
