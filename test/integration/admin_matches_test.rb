require "test_helper"
require "tempfile"

class AdminMatchesTest < ActionDispatch::IntegrationTest
  test "admins can archive and restore matches" do
    sign_in_as(users(:admin_user))
    match = matches(:open_match)

    patch archive_admin_match_path(match)
    assert match.reload.archived?

    patch restore_admin_match_path(match)
    assert_not match.reload.archived?
  end

  test "admins can import matches from csv" do
    sign_in_as(users(:admin_user))

    Tempfile.create(["schedule", ".csv"]) do |file|
      file.write("team_one,team_two,venue,starts_at\nPunjab Kings,Delhi Capitals,Delhi,2026-05-01 19:30:00 +05:30\n")
      file.rewind

      assert_difference("Match.count", 1) do
        post import_admin_matches_path, params: {
          schedule_csv: Rack::Test::UploadedFile.new(file.path, "text/csv")
        }
      end
    end

    assert_redirected_to admin_root_path
    assert Match.exists?(team_one: "Punjab Kings", team_two: "Delhi Capitals")
  end
end
