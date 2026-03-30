class AddRelationalIntegrityConstraints < ActiveRecord::Migration[8.1]
  def change
    add_index :matches, %i[starts_at team_one team_two], unique: true, name: "index_matches_on_identity"
    add_index :prediction_questions, %i[id match_id], unique: true, name: "index_prediction_questions_on_id_and_match_id"
    add_index :prediction_options, %i[id prediction_question_id], unique: true, name: "index_prediction_options_on_id_and_question_id"
    add_index :prediction_options, "prediction_question_id, LOWER(label)", unique: true, where: "archived_at IS NULL", name: "index_prediction_options_on_question_and_lower_label_active"

    execute <<~SQL
      ALTER TABLE predictions
      ADD CONSTRAINT fk_predictions_option_question
      FOREIGN KEY (prediction_option_id, prediction_question_id)
      REFERENCES prediction_options (id, prediction_question_id)
    SQL

    execute <<~SQL
      ALTER TABLE prediction_submissions
      ADD CONSTRAINT fk_prediction_submissions_option_question
      FOREIGN KEY (prediction_option_id, prediction_question_id)
      REFERENCES prediction_options (id, prediction_question_id)
    SQL

    execute <<~SQL
      ALTER TABLE prediction_submissions
      ADD CONSTRAINT fk_prediction_submissions_question_match
      FOREIGN KEY (prediction_question_id, match_id)
      REFERENCES prediction_questions (id, match_id)
    SQL

    execute <<~SQL
      ALTER TABLE prediction_questions
      ADD CONSTRAINT fk_prediction_questions_correct_option_question
      FOREIGN KEY (correct_option_id, id)
      REFERENCES prediction_options (id, prediction_question_id)
    SQL
  end
end
