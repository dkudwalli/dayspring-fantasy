class AdminAuditLogger
  def self.record!(admin:, action:, auditable: nil, auditable_type: nil, match: nil, metadata: {})
    new(
      admin: admin,
      action: action,
      auditable: auditable,
      auditable_type: auditable_type,
      match: match,
      metadata: metadata
    ).record!
  end

  def initialize(admin:, action:, auditable:, auditable_type:, match:, metadata:)
    @admin = admin
    @action = action
    @auditable = auditable
    @auditable_type = auditable_type
    @match = match
    @metadata = metadata
  end

  def record!
    log = AdminAuditLog.create!(
      admin_user: @admin,
      match: resolved_match,
      auditable: @auditable,
      auditable_type: resolved_auditable_type,
      auditable_id: @auditable&.id,
      action: @action,
      metadata: @metadata.deep_stringify_keys
    )

    Rails.logger.info("admin_audit action=#{log.action} admin_id=#{log.admin_user_id} auditable_type=#{log.auditable_type} auditable_id=#{log.auditable_id} match_id=#{log.match_id}")
    log
  rescue StandardError => error
    Rails.logger.error("admin_audit_failed action=#{@action} admin_id=#{@admin&.id} auditable_type=#{resolved_auditable_type} auditable_id=#{@auditable&.id} error_class=#{error.class} message=#{error.message}")
    Sentry.capture_exception(error, extra: {
      admin_id: @admin&.id,
      action: @action,
      auditable_type: resolved_auditable_type,
      auditable_id: @auditable&.id,
      match_id: resolved_match&.id
    }) if defined?(Sentry)
    raise
  end

  private

  def resolved_auditable_type
    @auditable_type.presence || @auditable&.class&.name || "Unknown"
  end

  def resolved_match
    return @match if @match.present?
    return @auditable if @auditable.is_a?(Match)

    @auditable&.try(:match)
  end
end
