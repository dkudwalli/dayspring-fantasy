# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_30_124000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "admin_user_id", null: false
    t.bigint "auditable_id"
    t.string "auditable_type", null: false
    t.datetime "created_at", null: false
    t.bigint "match_id"
    t.jsonb "metadata", default: {}, null: false
    t.index ["action"], name: "index_admin_audit_logs_on_action"
    t.index ["admin_user_id"], name: "index_admin_audit_logs_on_admin_user_id"
    t.index ["auditable_type", "auditable_id"], name: "index_admin_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_admin_audit_logs_on_created_at"
    t.index ["match_id"], name: "index_admin_audit_logs_on_match_id"
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "starts_at", null: false
    t.string "team_one", null: false
    t.string "team_two", null: false
    t.datetime "updated_at", null: false
    t.string "venue"
    t.index ["archived_at"], name: "index_matches_on_archived_at"
    t.index ["starts_at", "team_one", "team_two"], name: "index_matches_on_identity", unique: true
    t.index ["starts_at"], name: "index_matches_on_starts_at"
  end

  create_table "prediction_options", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.integer "position", default: 0, null: false
    t.bigint "prediction_question_id", null: false
    t.datetime "updated_at", null: false
    t.index "prediction_question_id, lower((label)::text)", name: "index_prediction_options_on_question_and_lower_label_active", unique: true, where: "(archived_at IS NULL)"
    t.index ["archived_at"], name: "index_prediction_options_on_archived_at"
    t.index ["id", "prediction_question_id"], name: "index_prediction_options_on_id_and_question_id", unique: true
    t.index ["prediction_question_id", "position"], name: "index_prediction_options_on_question_id_and_position"
    t.index ["prediction_question_id"], name: "index_prediction_options_on_prediction_question_id"
    t.check_constraint "\"position\" >= 0", name: "prediction_options_position_non_negative"
  end

  create_table "prediction_questions", force: :cascade do |t|
    t.datetime "archived_at"
    t.bigint "correct_option_id"
    t.datetime "created_at", null: false
    t.bigint "match_id", null: false
    t.integer "point_value", default: 1, null: false
    t.string "prompt", null: false
    t.datetime "result_published_at"
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_prediction_questions_on_archived_at"
    t.index ["correct_option_id"], name: "index_prediction_questions_on_correct_option_id"
    t.index ["id", "match_id"], name: "index_prediction_questions_on_id_and_match_id", unique: true
    t.index ["match_id"], name: "index_prediction_questions_on_match_id"
    t.index ["result_published_at"], name: "index_prediction_questions_on_result_published_at"
    t.check_constraint "point_value > 0", name: "prediction_questions_point_value_positive"
  end

  create_table "prediction_submissions", force: :cascade do |t|
    t.string "action_type", null: false
    t.datetime "created_at", null: false
    t.bigint "match_id", null: false
    t.bigint "prediction_option_id", null: false
    t.bigint "prediction_question_id", null: false
    t.datetime "submitted_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["match_id"], name: "index_prediction_submissions_on_match_id"
    t.index ["prediction_option_id"], name: "index_prediction_submissions_on_prediction_option_id"
    t.index ["prediction_question_id"], name: "index_prediction_submissions_on_prediction_question_id"
    t.index ["submitted_at"], name: "index_prediction_submissions_on_submitted_at"
    t.index ["user_id"], name: "index_prediction_submissions_on_user_id"
    t.check_constraint "action_type::text = ANY (ARRAY['created'::character varying::text, 'updated'::character varying::text])", name: "prediction_submissions_action_type_valid"
  end

  create_table "predictions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "prediction_option_id", null: false
    t.bigint "prediction_question_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["prediction_option_id"], name: "index_predictions_on_prediction_option_id"
    t.index ["prediction_question_id"], name: "index_predictions_on_prediction_question_id"
    t.index ["user_id", "prediction_question_id"], name: "index_predictions_on_user_id_and_prediction_question_id", unique: true
    t.index ["user_id"], name: "index_predictions_on_user_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "admin_audit_logs", "matches"
  add_foreign_key "admin_audit_logs", "users", column: "admin_user_id"
  add_foreign_key "prediction_options", "prediction_questions"
  add_foreign_key "prediction_questions", "matches"
  add_foreign_key "prediction_questions", "prediction_options", column: "correct_option_id"
  add_foreign_key "prediction_questions", "prediction_options", column: ["correct_option_id", "id"], primary_key: ["id", "prediction_question_id"], name: "fk_prediction_questions_correct_option_question"
  add_foreign_key "prediction_submissions", "matches"
  add_foreign_key "prediction_submissions", "prediction_options"
  add_foreign_key "prediction_submissions", "prediction_options", column: ["prediction_option_id", "prediction_question_id"], primary_key: ["id", "prediction_question_id"], name: "fk_prediction_submissions_option_question"
  add_foreign_key "prediction_submissions", "prediction_questions"
  add_foreign_key "prediction_submissions", "prediction_questions", column: ["prediction_question_id", "match_id"], primary_key: ["id", "match_id"], name: "fk_prediction_submissions_question_match"
  add_foreign_key "prediction_submissions", "users"
  add_foreign_key "predictions", "prediction_options"
  add_foreign_key "predictions", "prediction_options", column: ["prediction_option_id", "prediction_question_id"], primary_key: ["id", "prediction_question_id"], name: "fk_predictions_option_question"
  add_foreign_key "predictions", "prediction_questions"
  add_foreign_key "predictions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
