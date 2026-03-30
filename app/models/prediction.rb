class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :prediction_question
  belongs_to :prediction_option

  validates :user_id, uniqueness: { scope: :prediction_question_id }
  validate :option_belongs_to_question
  validate :question_must_be_open

  def correct?
    prediction_question.result_published? &&
      prediction_question.correct_option_id.present? &&
      prediction_question.correct_option_id == prediction_option_id
  end

  def earned_points
    correct? ? prediction_question.point_value : 0
  end

  private

  def option_belongs_to_question
    return if prediction_option.blank? || prediction_question.blank?
    return if prediction_option.prediction_question_id == prediction_question_id

    errors.add(:prediction_option_id, "must belong to the selected question")
  end

  def question_must_be_open
    return if prediction_question.blank? || prediction_question.open_for_predictions?

    if prediction_question.result_published?
      errors.add(:base, "Predictions are locked because results have been published")
    else
      errors.add(:base, "Predictions are locked once the match starts")
    end
  end
end
