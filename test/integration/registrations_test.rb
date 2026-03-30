require "test_helper"

class RegistrationsTest < ActionDispatch::IntegrationTest
  test "user can sign up with an allowed domain" do
    assert_difference("User.count", 1) do
      post registration_path, params: {
        user: {
          email: "new.user@dayspring.tech",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Your account has been created.", response.body
    assert_match "new.user@dayspring.tech", response.body
  end

  test "signup rejects disallowed domains" do
    assert_no_difference("User.count") do
      post registration_path, params: {
        user: {
          email: "blocked@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_content
    assert_match "must use @dayspringlabs.com or @dayspring.tech", response.body
  end

  test "sign-up attempts are rate limited" do
    10.times do
      post registration_path, params: {
        user: {
          email: "blocked@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_response :unprocessable_content
    end

    post registration_path, params: {
      user: {
        email: "blocked@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_redirected_to new_registration_path
    follow_redirect!
    assert_match "Too many sign-up attempts. Try again later.", response.body
  end
end
