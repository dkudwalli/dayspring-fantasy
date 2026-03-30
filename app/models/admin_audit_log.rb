class AdminAuditLog < ApplicationRecord
  belongs_to :admin_user, class_name: "User"
  belongs_to :match, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, :auditable_type, presence: true
  validate :admin_user_must_be_admin

  before_destroy :raise_read_only_record

  def readonly?
    persisted?
  end

  private

  def admin_user_must_be_admin
    return if admin_user&.admin?

    errors.add(:admin_user, "must be an admin")
  end

  def raise_read_only_record
    raise ActiveRecord::ReadOnlyRecord, "#{self.class.name} is append-only"
  end
end
