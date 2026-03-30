class PredictionSubmission < ApplicationRecord
  belongs_to :user
  belongs_to :match
  belongs_to :prediction_question
  belongs_to :prediction_option

  validates :action_type, :submitted_at, presence: true
  validates :action_type, inclusion: { in: %w[created updated] }
  validate :question_belongs_to_match
  validate :option_belongs_to_question

  private

  def question_belongs_to_match
    return if prediction_question.blank? || match.blank?
    return if prediction_question.match_id == match_id

    errors.add(:prediction_question_id, "must belong to the selected match")
  end

  def option_belongs_to_question
    return if prediction_option.blank? || prediction_question.blank?
    return if prediction_option.prediction_question_id == prediction_question_id

    errors.add(:prediction_option_id, "must belong to the selected question")
  end
end
