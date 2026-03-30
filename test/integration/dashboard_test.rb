require "test_helper"

class DashboardTest < ActionDispatch::IntegrationTest
  test "signed in users see the simplified match center metrics" do
    sign_in_as(users(:member))

    get root_path(date: matches(:open_match).starts_at.to_date)

    assert_response :success
    assert_match "League rank", response.body
    assert_no_match "Questions saved", response.body
    assert_no_match "Points today", response.body
    assert_no_match "Matches today", response.body
    assert_no_match "Schedule page", response.body
    assert_no_match "View your history", response.body
    assert_no_match "See full leaderboard", response.body
    assert_no_match "Full leaderboard", response.body
    assert_no_match "Your history", response.body
  end

  test "admin users keep top-nav access and see player rank" do
    sign_in_as(users(:admin_user))
    expected_rank = User.rank_for(users(:admin_user))

    get root_path(date: matches(:open_match).starts_at.to_date)

    assert_response :success
    assert_match "League rank", response.body
    assert_match "Admin", response.body
    assert_match "##{expected_rank}", response.body
  end
end
