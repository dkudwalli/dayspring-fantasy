require "test_helper"

class LeaderboardsTest < ActionDispatch::IntegrationTest
  test "admin users are excluded from the public leaderboard" do
    prediction_questions(:locked_winner).update!(
      correct_option: prediction_options(:locked_team_one_option),
      result_published_at: Time.current
    )

    get leaderboards_path

    assert_response :success
    assert_match users(:member).email, response.body
    assert_match users(:rival).email, response.body
    assert_no_match users(:admin_user).email, response.body
  end

  test "leaderboard paginates large user sets" do
    55.times do |index|
      User.create!(
        email: format("user%03d@dayspringlabs.com", index),
        password: "password123",
        password_confirmation: "password123"
      )
    end

    get leaderboards_path(page: 2)

    assert_response :success
    assert_match "Page 2 of 2", response.body
    assert_match "user054@dayspringlabs.com", response.body
  end
end
