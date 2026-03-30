require "application_system_test_case"

class AdminMatchManagementTest < ApplicationSystemTestCase
  test "admin archives and restores a match from the admin index" do
    visit new_session_path
    fill_in "Email", with: users(:admin_user).email
    fill_in "Password", with: "password123"
    click_button "Login"

    click_link "Admin"
    assert_text "Matches"

    match = matches(:open_match)

    within(".leaderboard-row", text: match.name) do
      click_button "Archive"
    end

    assert_text "#{match.name} · Archived"

    within(".leaderboard-row", text: match.name) do
      click_button "Restore"
    end

    assert_text match.name
    assert_no_text "#{match.name} · Archived"
  end
end
