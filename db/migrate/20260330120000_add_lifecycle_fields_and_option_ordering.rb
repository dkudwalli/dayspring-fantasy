class AddLifecycleFieldsAndOptionOrdering < ActiveRecord::Migration[8.1]
  def change
    add_column :matches, :archived_at, :datetime
    add_column :prediction_questions, :archived_at, :datetime
    add_column :prediction_questions, :result_published_at, :datetime
    add_column :prediction_options, :archived_at, :datetime
    add_column :prediction_options, :position, :integer, null: false, default: 0

    add_index :matches, :archived_at
    add_index :prediction_questions, :archived_at
    add_index :prediction_questions, :result_published_at
    add_index :prediction_options, :archived_at
    add_index :prediction_options, %i[prediction_question_id position], name: "index_prediction_options_on_question_id_and_position"
  end
end
