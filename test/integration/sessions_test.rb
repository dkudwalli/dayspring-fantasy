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

  test "invalid credentials re-render the form" do
    post session_path, params: {
      email: users(:member).email,
      password: "wrong-password"
    }

    assert_response :unprocessable_content
    assert_match "Invalid email or password.", response.body
  end
end
