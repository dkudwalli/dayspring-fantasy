class CreatePredictions < ActiveRecord::Migration[7.1]
  def change
    create_table :predictions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :prediction_question, null: false, foreign_key: true
      t.references :prediction_option, null: false, foreign_key: true

      t.timestamps
    end

    add_index :predictions, %i[user_id prediction_question_id], unique: true
  end
end
