class CreatePredictionSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :prediction_submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true
      t.references :prediction_question, null: false, foreign_key: true
      t.references :prediction_option, null: false, foreign_key: true
      t.string :action_type, null: false
      t.datetime :submitted_at, null: false

      t.timestamps
    end

    add_index :prediction_submissions, :submitted_at
  end
end
