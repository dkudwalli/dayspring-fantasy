class CreatePredictionQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :prediction_questions do |t|
      t.references :match, null: false, foreign_key: true
      t.string :prompt, null: false
      t.integer :point_value, null: false, default: 1
      t.bigint :correct_option_id

      t.timestamps
    end

    add_index :prediction_questions, :correct_option_id
  end
end
