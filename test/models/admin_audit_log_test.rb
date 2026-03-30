require "test_helper"

class AdminAuditLogTest < ActiveSupport::TestCase
  test "requires the actor to be an admin user" do
    log = AdminAuditLog.new(
      admin_user: users(:member),
      auditable_type: "Match",
      auditable_id: matches(:open_match).id,
      action: "match_created",
      metadata: {},
      created_at: Time.current
    )

    assert_not log.valid?
    assert_includes log.errors[:admin_user], "must be an admin"
  end

  test "is append-only once created" do
    log = AdminAuditLog.create!(
      admin_user: users(:admin_user),
      auditable_type: "Match",
      auditable_id: matches(:open_match).id,
      action: "match_created",
      metadata: {},
      created_at: Time.current
    )

    assert_raises(ActiveRecord::ReadOnlyRecord) do
      log.update!(action: "match_updated")
    end

    assert_raises(ActiveRecord::ReadOnlyRecord) do
      log.destroy
    end
  end
end
