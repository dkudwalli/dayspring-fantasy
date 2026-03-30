require "application_system_test_case"

class AdminMatchManagementTest < ApplicationSystemTestCase
  test "admin archives and restores a match from the admin index" do
    visit new_session_path
    fill_in "Email", with: users(:admin_user).email
    fill_in "Password", with: "password123"
    click_button "Log in"

    click_link "Admin"
    assert_text "Match operations"

    match = matches(:open_match)

    within("tr", text: match.name) do
      click_button "Archive"
    end

    within("tr", text: match.name) do
      assert_text "Archived"
    end

    within("tr", text: match.name) do
      click_button "Restore"
    end

    within("tr", text: match.name) do
      assert_text "Active"
      assert_no_text "Archived"
    end
  end
end
