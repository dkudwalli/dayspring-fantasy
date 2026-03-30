class CreatePredictionOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :prediction_options do |t|
      t.references :prediction_question, null: false, foreign_key: true
      t.string :label, null: false

      t.timestamps
    end
  end
end
