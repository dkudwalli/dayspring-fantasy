require "application_system_test_case"

class UserHistoryJourneyTest < ApplicationSystemTestCase
  test "user signs in, visits history, and signs out" do
    visit new_session_path
    fill_in "Email", with: users(:member).email
    fill_in "Password", with: "password123"
    click_button "Login"

    assert_text "Your score"
    click_link "History"

    assert_text "Your picks and results"
    assert_text matches(:open_match).name

    click_button "Logout"
    assert_text "You have been logged out."
    assert_text "Login"
  end
end
