require "application_system_test_case"

class UserHistoryJourneyTest < ApplicationSystemTestCase
  test "user signs in, visits history, and signs out" do
    visit new_session_path
    fill_in "Email", with: users(:member).email
    fill_in "Password", with: "password123"
    click_button "Log in"

    assert_text "Questions saved"
    click_link "History"

    assert_text "Your picks timeline"
    assert_text matches(:open_match).name

    click_button "Log out"
    assert_text "You have been logged out."
    assert_text "Log in"
  end
end
