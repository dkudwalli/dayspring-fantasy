class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  private

  def audit_admin_action!(action:, auditable: nil, auditable_type: nil, match: nil, metadata: {})
    AdminAuditLogger.record!(
      admin: current_user,
      action: action,
      auditable: auditable,
      auditable_type: auditable_type,
      match: match,
      metadata: metadata
    )
  end
end
