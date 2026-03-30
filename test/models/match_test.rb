require "test_helper"

class MatchTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test ".on_date returns matches on the requested day in start order" do
    assert_equal [matches(:open_match)], Match.on_date(Date.new(2026, 4, 10)).to_a
    assert_equal [matches(:locked_match)], Match.on_date(Date.new(2026, 4, 5)).to_a
  end

  test "#locked? becomes true at match start time" do
    match = matches(:open_match)

    travel_to(Time.zone.parse("2026-04-10 19:29:59")) do
      assert_not match.locked?
    end

    travel_to(Time.zone.parse("2026-04-10 19:30:00")) do
      assert match.locked?
    end
  end

  test ".visible_to_users excludes archived matches" do
    matches(:open_match).archive!

    assert_equal [matches(:locked_match)], Match.visible_to_users.on_date(Date.new(2026, 4, 5)).to_a
    assert_empty Match.visible_to_users.on_date(Date.new(2026, 4, 10)).to_a
  end
end
