class CreateAdminAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_audit_logs do |t|
      t.references :admin_user, null: false, foreign_key: { to_table: :users }
      t.references :match, foreign_key: true
      t.string :auditable_type, null: false
      t.bigint :auditable_id
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}
      t.datetime :created_at, null: false
    end

    add_index :admin_audit_logs, :action
    add_index :admin_audit_logs, %i[auditable_type auditable_id]
    add_index :admin_audit_logs, :created_at
  end
end
