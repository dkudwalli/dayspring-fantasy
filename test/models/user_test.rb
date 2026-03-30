require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes allowed email addresses before validation" do
    user = User.new(
      email: "  Mixed.Case@DayspringLabs.com ",
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?
    assert_equal "mixed.case@dayspringlabs.com", user.email
  end

  test "rejects disallowed email domains" do
    user = User.new(
      email: "fan@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_not user.valid?
    assert_includes user.errors[:email], "must use @dayspringlabs.com or @dayspring.tech"
  end

  test "#score sums the point value of correct predictions only" do
    prediction_questions(:locked_winner).update!(
      correct_option: prediction_options(:locked_team_one_option),
      result_published_at: Time.current
    )

    assert_equal 4, users(:member).score
    assert_equal 0, users(:rival).score
  end
end
