class AddPredictionIntegrityConstraints < ActiveRecord::Migration[8.1]
  def up
    add_check_constraint :prediction_options, "position >= 0", name: "prediction_options_position_non_negative"
    add_check_constraint :prediction_questions, "point_value > 0", name: "prediction_questions_point_value_positive"
    add_check_constraint :prediction_submissions, "action_type IN ('created', 'updated')", name: "prediction_submissions_action_type_valid"
  end

  def down
    remove_check_constraint :prediction_submissions, name: "prediction_submissions_action_type_valid"
    remove_check_constraint :prediction_questions, name: "prediction_questions_point_value_positive"
    remove_check_constraint :prediction_options, name: "prediction_options_position_non_negative"
  end
end
