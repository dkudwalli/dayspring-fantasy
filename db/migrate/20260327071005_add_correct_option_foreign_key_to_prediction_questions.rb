class AddCorrectOptionForeignKeyToPredictionQuestions < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :prediction_questions, :prediction_options, column: :correct_option_id
  end
end
