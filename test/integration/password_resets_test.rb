require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  test "requesting a password reset enqueues an email job for known users" do
    assert_enqueued_with(job: PasswordResetDeliveryJob, args: [users(:member).id]) do
      post password_resets_path, params: { email: users(:member).email }
    end

    assert_redirected_to new_session_path
  end

  test "requesting a password reset does not reveal whether the account exists" do
    assert_no_enqueued_jobs do
      post password_resets_path, params: { email: "missing@dayspringlabs.com" }
    end

    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "If an account exists for that email, a reset link has been sent.", response.body
  end

  test "queued password reset delivery sends the email when jobs are performed" do
    perform_enqueued_jobs do
      post password_resets_path, params: { email: users(:member).email }
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_redirected_to new_session_path
  end

  test "users can reset their password with a valid token" do
    token = users(:member).generate_token_for(:password_reset)

    patch password_reset_path(token), params: {
      user: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "Your password has been updated.", response.body

    post session_path, params: { email: users(:member).email, password: "newpassword123" }
    assert_redirected_to root_path
  end

  test "invalid password reset tokens are rejected" do
    get edit_password_reset_path("bad-token")

    assert_redirected_to new_password_reset_path
  end
end
