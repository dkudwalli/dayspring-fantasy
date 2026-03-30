require "test_helper"

class AdminActivityLogsTest < ActionDispatch::IntegrationTest
  test "admin actions are written to the activity log and can be filtered" do
    sign_in_as(users(:admin_user))
    match = matches(:open_match)

    assert_difference("AdminAuditLog.count", 1) do
      patch archive_admin_match_path(match)
    end

    assert_redirected_to admin_root_path

    get admin_activity_logs_path, params: { log_action: "match_archived" }

    assert_response :success
    assert_match "Activity Logs", response.body
    assert_match "match_archived", response.body
    assert_match users(:admin_user).email, response.body
    assert_match match.team_one, response.body
  end
end
